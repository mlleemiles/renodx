/*
 * Copyright (C) 2024 Carlos Lopez
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64

//#define DEBUG_LEVEL_0
//#define DEBUG_LEVEL_1
//#define DEBUG_LEVEL_2

#define RESHADE_AO
#define REMOVE_UI

#include <embed/shaders.h>

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>

#include "../../mods/shader.hpp"
#include "../../mods/swapchain.hpp"
#include "../../templates/settings.hpp"
#include "../../utils/date.hpp"
#include "../../utils/trace.hpp"
#include "../../utils/settings.hpp"
#include "./shared.h"

namespace {
  
#ifdef RESHADE_AO
struct ComputePipeline
{
    reshade::api::pipeline pipeline{};
    reshade::api::pipeline_layout layout{};
    reshade::api::descriptor_table descriptor_table{};

    void destroy(reshade::api::device* device)
    {
        if (pipeline.handle)
        {
            device->destroy_pipeline(pipeline);
            pipeline = {};
        }

        if (descriptor_table.handle)
        {
            device->free_descriptor_table(descriptor_table);
            descriptor_table = {};
        }

        if (layout.handle)
        {
            device->destroy_pipeline_layout(layout);
            layout = {};
        }
    }
};

struct TextureWithViews
{
    reshade::api::resource texture{};
    std::vector<reshade::api::resource_view> uavs;
    std::vector<reshade::api::resource_view> srvs;

    void destroy(reshade::api::device* device)
    {
        for (auto& uav : uavs)
        {
            if (uav.handle)
                device->destroy_resource_view(uav);
        }
        uavs.clear();

        for (auto& srv : srvs)
        {
            if (srv.handle)
                device->destroy_resource_view(srv);
        }
        srvs.clear();

        if (texture.handle)
        {
            device->destroy_resource(texture);
            texture = {};
        }
    }
};

namespace PipelineHelpers
{
    inline uint32_t GetMaxMipCount(uint32_t width, uint32_t height)
    {
        uint32_t size = std::max(width, height);
        return 32 - std::countl_zero(size);
    }

    inline bool create_compute_pipeline(
        reshade::api::device* device,
        reshade::api::shader_desc& shader,
        const reshade::api::pipeline_layout_param* params,
        uint32_t param_count,
        ComputePipeline& out)
    {
        if (!device->create_pipeline_layout(param_count, params, &out.layout))
            return false;

        reshade::api::pipeline_subobject sub{};
        sub.type = reshade::api::pipeline_subobject_type::compute_shader;
        sub.count = 1;
        sub.data = &shader;

        if (!device->create_pipeline(out.layout, 1, &sub, &out.pipeline))
            return false;

        return true;
    }
}

struct XeGTAODepthFilter
{
    ComputePipeline pipeline;
    TextureWithViews working_depth;

    void setup(reshade::api::device* device)
    {
        reshade::api::shader_desc shader{};
        shader.code = __XeGTAO_PrefilterDepths.data();
        shader.code_size = __XeGTAO_PrefilterDepths.size();

        reshade::api::pipeline_layout_param params[3]{};

        // Table 0
        reshade::api::descriptor_range table0[7]{};

        for (uint32_t i = 0; i < 5; ++i)
        {
            table0[i] = {
                .binding = i,
                .dx_register_index = 0,
                .dx_register_space = 0,
                .count = 1,
                .visibility = reshade::api::shader_stage::compute,
                .array_size = 1,
                .type = reshade::api::descriptor_type::texture_unordered_access_view
            };
        }

        table0[5] = {
            .binding = 5,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_shader_resource_view
        };

        table0[6] = {
            .binding = 6,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::sampler
        };

        // Table 1
        reshade::api::descriptor_range table1[2]{};
        for (uint32_t i = 0; i < 2; ++i)
        {
            table1[i] = {
                .binding = i,
                .dx_register_index = 0,
                .dx_register_space = 0,
                .count = 1,
                .visibility = reshade::api::shader_stage::compute,
                .array_size = 1,
                .type = reshade::api::descriptor_type::constant_buffer
            };
        }

        // Table 2
        reshade::api::descriptor_range table2[5]{};
        for (uint32_t i = 0; i < 5; ++i)
        {
            table2[i] = {
                .binding = i,
                .dx_register_index = 0,
                .dx_register_space = 0,
                .count = 1,
                .visibility = reshade::api::shader_stage::compute,
                .array_size = 1,
                .type = reshade::api::descriptor_type::texture_unordered_access_view
            };
        }

        params[0] = reshade::api::pipeline_layout_param(7, table0);
        params[1] = reshade::api::pipeline_layout_param(2, table1);
        params[2] = reshade::api::pipeline_layout_param(5, table2);

        bool ok = PipelineHelpers::create_compute_pipeline(
            device, shader, params, 3, pipeline);

        reshade::log::message(reshade::log::level::info, "Logging working depth created layout");
        renodx::utils::trace::internal::LogLayout(3, params, pipeline.layout);

        assert(ok);

        device->allocate_descriptor_table(
            pipeline.layout, 2, &pipeline.descriptor_table);
    }

    void create_resources(
        reshade::api::device* device,
        uint32_t width,
        uint32_t height)
    {
        uint32_t mipCount =
            PipelineHelpers::GetMaxMipCount(width, height);

        reshade::api::resource_desc desc(
            reshade::api::resource_type::texture_2d,
            width,
            height,
            1,
            mipCount,
            reshade::api::format::r32_float,
            1,
            reshade::api::memory_heap::gpu_only,
            reshade::api::resource_usage::unordered_access |
            reshade::api::resource_usage::copy_source |
            reshade::api::resource_usage::copy_dest |
            reshade::api::resource_usage::shader_resource |
            reshade::api::resource_usage::render_target,
            reshade::api::resource_flags::none);

        device->create_resource(desc, nullptr, desc.usage, &working_depth.texture);

        working_depth.uavs.resize(5);

        for (uint32_t i = 0; i < 5; ++i)
        {
            reshade::api::resource_view_desc view{};
            view.type = reshade::api::resource_view_type::texture_2d;
            view.format = reshade::api::format::r32_float;
            view.texture.first_level = i;
            view.texture.level_count = 1;

            device->create_resource_view(
                working_depth.texture,
                reshade::api::resource_usage::unordered_access,
                view,
                &working_depth.uavs[i]);
        }

        working_depth.srvs.resize(1);

        for (uint32_t i = 0; i < 1; ++i)
        {
            reshade::api::resource_view_desc view{};
            view.type = reshade::api::resource_view_type::texture_2d;
            view.format = reshade::api::format::r32_float;
            view.texture.first_level = i;
            view.texture.level_count = mipCount;

            device->create_resource_view(
                working_depth.texture,
                reshade::api::resource_usage::shader_resource,
                view,
                &working_depth.srvs[i]);
        }
    }

    void update_descriptor_table(
        reshade::api::device* device)
    {
        reshade::api::descriptor_table_update updates[5]{};

        for (uint32_t i = 0; i < 5; ++i)
        {
            updates[i].table = pipeline.descriptor_table;
            updates[i].binding = i;
            updates[i].array_offset = 0;
            updates[i].count = 1;
            updates[i].type = reshade::api::descriptor_type::texture_unordered_access_view;
            updates[i].descriptors = &working_depth.uavs[i];
        }

        device->update_descriptor_tables(5, updates);
    }

    void destroy(reshade::api::device* device)
    {
        working_depth.destroy(device);
        pipeline.destroy(device);
    }
};

struct XeGTAOMainPass
{
    ComputePipeline pipeline;
    TextureWithViews working_ao;
    TextureWithViews working_normal;

    void setup(reshade::api::device* device)
    {
        reshade::api::shader_desc shader{};
        shader.code = __XeGTAO_MainPass.data();
        shader.code_size = __XeGTAO_MainPass.size();

        reshade::api::pipeline_layout_param params[3]{};

        // Table 0
        reshade::api::descriptor_range table0[4]{};

        table0[0] = {
            .binding = 0,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_unordered_access_view
        };

        for (uint32_t i = 1; i < 3; ++i)
        {
          table0[i] = {
              .binding = i,
              .dx_register_index = 0,
              .dx_register_space = 0,
              .count = 1,
              .visibility = reshade::api::shader_stage::compute,
              .array_size = 1,
              .type = reshade::api::descriptor_type::texture_shader_resource_view
          };
        }

        table0[3] = {
            .binding = 3,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::sampler
        };

        // Table 1
        reshade::api::descriptor_range table1[2]{};
        for (uint32_t i = 0; i < 2; ++i)
        {
            table1[i] = {
                .binding = i,
                .dx_register_index = 0,
                .dx_register_space = 0,
                .count = 1,
                .visibility = reshade::api::shader_stage::compute,
                .array_size = 1,
                .type = reshade::api::descriptor_type::constant_buffer
            };
        }

        // Table 2
        reshade::api::descriptor_range table2[3]{};
        table2[0] = {
            .binding = 0,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_unordered_access_view
        };

        table2[1] = {
            .binding = 1,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_unordered_access_view
        };

        table2[2] = {
            .binding = 2,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_shader_resource_view
        };

        params[0] = reshade::api::pipeline_layout_param(4, table0);
        params[1] = reshade::api::pipeline_layout_param(2, table1);
        params[2] = reshade::api::pipeline_layout_param(3, table2);

        bool ok = PipelineHelpers::create_compute_pipeline(
            device, shader, params, 3, pipeline);

        reshade::log::message(reshade::log::level::info, "Logging working ao created layout");
        renodx::utils::trace::internal::LogLayout(3, params, pipeline.layout);

        assert(ok);

        device->allocate_descriptor_table(
            pipeline.layout, 2, &pipeline.descriptor_table);
    }

    void create_resources(
        reshade::api::device* device,
        uint32_t width,
        uint32_t height)
    {
        reshade::api::resource_desc desc(
            reshade::api::resource_type::texture_2d,
            width,
            height,
            1,
            1,
            reshade::api::format::r8_unorm,
            1,
            reshade::api::memory_heap::gpu_only,
            reshade::api::resource_usage::unordered_access |
            reshade::api::resource_usage::copy_source |
            reshade::api::resource_usage::copy_dest |
            reshade::api::resource_usage::shader_resource |
            reshade::api::resource_usage::render_target,
            reshade::api::resource_flags::none);

        reshade::api::resource_desc desc_normal(
            reshade::api::resource_type::texture_2d,
            width,
            height,
            1,
            1,
            reshade::api::format::r10g10b10a2_unorm,
            1,
            reshade::api::memory_heap::gpu_only,
            reshade::api::resource_usage::unordered_access |
            reshade::api::resource_usage::copy_source |
            reshade::api::resource_usage::copy_dest |
            reshade::api::resource_usage::shader_resource |
            reshade::api::resource_usage::render_target,
            reshade::api::resource_flags::none);

        device->create_resource(desc, nullptr, desc.usage, &working_ao.texture);
        device->create_resource(desc_normal, nullptr, desc_normal.usage, &working_normal.texture);

        // UAV
        working_ao.uavs.resize(1);
        working_normal.uavs.resize(1);

        for (uint32_t i = 0; i < 1; ++i)
        {
            reshade::api::resource_view_desc view{};
            view.type = reshade::api::resource_view_type::texture_2d;
            view.format = reshade::api::format::r8_unorm;
            view.texture.first_level = 0;
            view.texture.level_count = 1;

            reshade::api::resource_view_desc view_normal{};
            view_normal.type = reshade::api::resource_view_type::texture_2d;
            view_normal.format = reshade::api::format::r10g10b10a2_unorm;
            view_normal.texture.first_level = 0;
            view_normal.texture.level_count = 1;

            device->create_resource_view(
                working_ao.texture,
                reshade::api::resource_usage::unordered_access,
                view,
                &working_ao.uavs[i]);

            device->create_resource_view(
                working_normal.texture,
                reshade::api::resource_usage::unordered_access,
                view_normal,
                &working_normal.uavs[i]);
        }

        // SRV
        working_ao.srvs.resize(1);
        working_normal.srvs.resize(1);

        for (uint32_t i = 0; i < 1; ++i)
        {
            reshade::api::resource_view_desc view{};
            view.type = reshade::api::resource_view_type::texture_2d;
            view.format = reshade::api::format::r8_unorm;
            view.texture.first_level = 0;
            view.texture.level_count = 1;

            reshade::api::resource_view_desc view_normal{};
            view_normal.type = reshade::api::resource_view_type::texture_2d;
            view_normal.format = reshade::api::format::r10g10b10a2_unorm;
            view_normal.texture.first_level = 0;
            view_normal.texture.level_count = 1;

            device->create_resource_view(
                working_ao.texture,
                reshade::api::resource_usage::shader_resource,
                view,
                &working_ao.srvs[i]);

            device->create_resource_view(
                working_normal.texture,
                reshade::api::resource_usage::shader_resource,
                view_normal,
                &working_normal.srvs[i]);
        }
    }

    void update_descriptor_table(
        reshade::api::device* device,
        const reshade::api::resource_view& depth_srv)
    {
        // Descriptor updates
        reshade::api::descriptor_table_update updates[3]{};

        // Working AO
        updates[0].table = pipeline.descriptor_table;
        updates[0].binding = 0;
        updates[0].array_offset = 0;
        updates[0].count = 1;
        updates[0].type = reshade::api::descriptor_type::texture_unordered_access_view;
        updates[0].descriptors = &working_ao.uavs[0];

        // Working Normal
        updates[1].table = pipeline.descriptor_table;
        updates[1].binding = 1;
        updates[1].array_offset = 0;
        updates[1].count = 1;
        updates[1].type = reshade::api::descriptor_type::texture_unordered_access_view;
        updates[1].descriptors = &working_normal.uavs[0];

        // Depth SRV
        updates[2].table = pipeline.descriptor_table;
        updates[2].binding = 2;
        updates[2].array_offset = 0;
        updates[2].count = 1;
        updates[2].type = reshade::api::descriptor_type::texture_shader_resource_view;
        updates[2].descriptors = &depth_srv;

        device->update_descriptor_tables(3, updates);
    }

    void destroy(reshade::api::device* device)
    {
        working_ao.destroy(device);
        working_normal.destroy(device);
        pipeline.destroy(device);
    }
};

struct XeGTAOTemporalAccumulation
{
    ComputePipeline pipeline;
    TextureWithViews accumulated_ao;

    void setup(reshade::api::device* device)
    {
        reshade::api::shader_desc shader{};
        shader.code = __XeGTAO_TemporalAccumulation.data();
        shader.code_size = __XeGTAO_TemporalAccumulation.size();

        reshade::api::pipeline_layout_param params[3]{};

        // Table 0
        reshade::api::descriptor_range table0[6]{};

        table0[0] = {
            .binding = 0,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_unordered_access_view
        };

        for (uint32_t i = 1; i < 5; ++i)
        {
          table0[i] = {
              .binding = i,
              .dx_register_index = 0,
              .dx_register_space = 0,
              .count = 1,
              .visibility = reshade::api::shader_stage::compute,
              .array_size = 1,
              .type = reshade::api::descriptor_type::texture_shader_resource_view
          };
        }

        table0[5] = {
            .binding = 5,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::sampler
        };

        // Table 1
        reshade::api::descriptor_range table1[2]{};
        for (uint32_t i = 0; i < 2; ++i)
        {
            table1[i] = {
                .binding = i,
                .dx_register_index = 0,
                .dx_register_space = 0,
                .count = 1,
                .visibility = reshade::api::shader_stage::compute,
                .array_size = 1,
                .type = reshade::api::descriptor_type::constant_buffer
            };
        }

        // Table 2
        // Temporal AO output
        reshade::api::descriptor_range table2[7]{};
        table2[0] = {
            .binding = 0,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_unordered_access_view
        };
        // Current AO
        table2[1] = {
            .binding = 1,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_shader_resource_view
        };
        // Current depth
        table2[2] = {
            .binding = 2,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_shader_resource_view
        };
        // Current normal
        table2[3] = {
            .binding = 3,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_shader_resource_view
        };
        // Previous denoised AO
        table2[4] = {
            .binding = 4,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_shader_resource_view
        };
        // Previous depth
        table2[5] = {
            .binding = 5,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_shader_resource_view
        };
        // Previous normal
        table2[6] = {
            .binding = 6,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_shader_resource_view
        };

        params[0] = reshade::api::pipeline_layout_param(6, table0);
        params[1] = reshade::api::pipeline_layout_param(2, table1);
        params[2] = reshade::api::pipeline_layout_param(7, table2);

        bool ok = PipelineHelpers::create_compute_pipeline(
            device, shader, params, 3, pipeline);

        reshade::log::message(reshade::log::level::info, "Logging temporal ao created layout");
        renodx::utils::trace::internal::LogLayout(3, params, pipeline.layout);

        assert(ok);

        device->allocate_descriptor_table(
            pipeline.layout, 2, &pipeline.descriptor_table);
    }

    void create_resources(
        reshade::api::device* device,
        uint32_t width,
        uint32_t height)
    {
        reshade::api::resource_desc desc(
            reshade::api::resource_type::texture_2d,
            width,
            height,
            1,
            1,
            reshade::api::format::r8g8_unorm,
            1,
            reshade::api::memory_heap::gpu_only,
            reshade::api::resource_usage::unordered_access |
            reshade::api::resource_usage::copy_source |
            reshade::api::resource_usage::copy_dest |
            reshade::api::resource_usage::shader_resource |
            reshade::api::resource_usage::render_target,
            reshade::api::resource_flags::none);

        device->create_resource(desc, nullptr, desc.usage, &accumulated_ao.texture);

        // UAV
        accumulated_ao.uavs.resize(1);

        for (uint32_t i = 0; i < 1; ++i)
        {
            reshade::api::resource_view_desc view{};
            view.type = reshade::api::resource_view_type::texture_2d;
            view.format = reshade::api::format::r8g8_unorm;
            view.texture.first_level = 0;
            view.texture.level_count = 1;

            device->create_resource_view(
                accumulated_ao.texture,
                reshade::api::resource_usage::unordered_access,
                view,
                &accumulated_ao.uavs[i]);
        }

        // SRV
        accumulated_ao.srvs.resize(1);

        for (uint32_t i = 0; i < 1; ++i)
        {
            reshade::api::resource_view_desc view{};
            view.type = reshade::api::resource_view_type::texture_2d;
            view.format = reshade::api::format::r8g8_unorm;
            view.texture.first_level = 0;
            view.texture.level_count = 1;

            device->create_resource_view(
                accumulated_ao.texture,
                reshade::api::resource_usage::shader_resource,
                view,
                &accumulated_ao.srvs[i]);
        }
    }

    void update_descriptor_table(
        reshade::api::device* device,
        const reshade::api::resource_view& ao_srv,
        const reshade::api::resource_view& depth_srv,
        const reshade::api::resource_view& normal_srv,
        const reshade::api::resource_view& prev_ao_srv,
        const reshade::api::resource_view& prev_depth_srv,
        const reshade::api::resource_view& prev_normal_srv)
    {
        // Descriptor updates
        reshade::api::descriptor_table_update updates[7]{};

        // UAV
        updates[0].table = pipeline.descriptor_table;
        updates[0].binding = 0;
        updates[0].array_offset = 0;
        updates[0].count = 1;
        updates[0].type = reshade::api::descriptor_type::texture_unordered_access_view;
        updates[0].descriptors = &accumulated_ao.uavs[0];

        // AO SRV
        updates[1].table = pipeline.descriptor_table;
        updates[1].binding = 1;
        updates[1].array_offset = 0;
        updates[1].count = 1;
        updates[1].type = reshade::api::descriptor_type::texture_shader_resource_view;
        updates[1].descriptors = &ao_srv;

        // Depth SRV
        updates[2].table = pipeline.descriptor_table;
        updates[2].binding = 2;
        updates[2].array_offset = 0;
        updates[2].count = 1;
        updates[2].type = reshade::api::descriptor_type::texture_shader_resource_view;
        updates[2].descriptors = &depth_srv;

        // Normal SRV
        updates[3].table = pipeline.descriptor_table;
        updates[3].binding = 3;
        updates[3].array_offset = 0;
        updates[3].count = 1;
        updates[3].type = reshade::api::descriptor_type::texture_shader_resource_view;
        updates[3].descriptors = &normal_srv;

        // Prev AO SRV
        updates[4].table = pipeline.descriptor_table;
        updates[4].binding = 4;
        updates[4].array_offset = 0;
        updates[4].count = 1;
        updates[4].type = reshade::api::descriptor_type::texture_shader_resource_view;
        updates[4].descriptors = &prev_ao_srv;

        // Prev Depth SRV
        updates[5].table = pipeline.descriptor_table;
        updates[5].binding = 5;
        updates[5].array_offset = 0;
        updates[5].count = 1;
        updates[5].type = reshade::api::descriptor_type::texture_shader_resource_view;
        updates[5].descriptors = &prev_depth_srv;

        // Prev Normal SRV
        updates[6].table = pipeline.descriptor_table;
        updates[6].binding = 6;
        updates[6].array_offset = 0;
        updates[6].count = 1;
        updates[6].type = reshade::api::descriptor_type::texture_shader_resource_view;
        updates[6].descriptors = &prev_normal_srv;

        device->update_descriptor_tables(7, updates);
    }

    void destroy(reshade::api::device* device)
    {
        accumulated_ao.destroy(device);
        pipeline.destroy(device);
    }
};

struct XeGTAODenoise
{
    ComputePipeline pipeline;
    TextureWithViews out_ao;
    TextureWithViews out_depth;
    TextureWithViews out_normal;

    void setup(reshade::api::device* device)
    {
        reshade::api::shader_desc shader{};
        shader.code = __XeGTAO_Denoise_Blur.data();
        shader.code_size = __XeGTAO_Denoise_Blur.size();

        reshade::api::pipeline_layout_param params[3]{};

        // Table 0
        reshade::api::descriptor_range table0[3]{};
        table0[0] = {
            .binding = 0,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_unordered_access_view
        };

        table0[1] = {
            .binding = 1,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_shader_resource_view
        };

        table0[2] = {
            .binding = 2,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::sampler
        };

        // Table 1
        reshade::api::descriptor_range table1[2]{};
        for (uint32_t i = 0; i < 2; ++i)
        {
            table1[i] = {
                .binding = i,
                .dx_register_index = 0,
                .dx_register_space = 0,
                .count = 1,
                .visibility = reshade::api::shader_stage::compute,
                .array_size = 1,
                .type = reshade::api::descriptor_type::constant_buffer
            };
        }

        // Table 2
        // AO Blur output
        reshade::api::descriptor_range table2[6]{};
        table2[0] = {
            .binding = 0,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_unordered_access_view
        };
        // Depth output
        table2[1] = {
            .binding = 1,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_unordered_access_view
        };
        // Normal output
        table2[2] = {
            .binding = 2,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_unordered_access_view
        };
        // AO Blur input
        table2[3] = {
            .binding = 3,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_shader_resource_view
        };
        // Current depth
        table2[4] = {
            .binding = 4,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_shader_resource_view
        };
         // Current normal
        table2[5] = {
            .binding = 5,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_shader_resource_view
        };

        params[0] = reshade::api::pipeline_layout_param(3, table0);
        params[1] = reshade::api::pipeline_layout_param(2, table1);
        params[2] = reshade::api::pipeline_layout_param(6, table2);

        bool ok = PipelineHelpers::create_compute_pipeline(
            device, shader, params, 3, pipeline);
        assert(ok);

        reshade::log::message(reshade::log::level::info, "Logging denoise ao created layout");
        renodx::utils::trace::internal::LogLayout(3, params, pipeline.layout);

        device->allocate_descriptor_table(
            pipeline.layout, 2, &pipeline.descriptor_table);
    }

    void create_resources(
        reshade::api::device* device,
        uint32_t width,
        uint32_t height)
    {
        {
            reshade::api::resource_desc desc(
                reshade::api::resource_type::texture_2d,
                width,
                height,
                1,
                1,
                reshade::api::format::r8g8_unorm,
                1,
                reshade::api::memory_heap::gpu_only,
                reshade::api::resource_usage::unordered_access |
                reshade::api::resource_usage::copy_source |
                reshade::api::resource_usage::copy_dest |
                reshade::api::resource_usage::shader_resource |
                reshade::api::resource_usage::render_target,
                reshade::api::resource_flags::none);

            reshade::api::resource_desc desc_normal(
                reshade::api::resource_type::texture_2d,
                width,
                height,
                1,
                1,
                reshade::api::format::r10g10b10a2_unorm,
                1,
                reshade::api::memory_heap::gpu_only,
                reshade::api::resource_usage::unordered_access |
                reshade::api::resource_usage::copy_source |
                reshade::api::resource_usage::copy_dest |
                reshade::api::resource_usage::shader_resource |
                reshade::api::resource_usage::render_target,
                reshade::api::resource_flags::none);

            device->create_resource(desc, nullptr, desc.usage, &out_ao.texture);
            device->create_resource(desc_normal, nullptr, desc_normal.usage, &out_normal.texture);
        }

        {
            reshade::api::resource_desc desc(
                reshade::api::resource_type::texture_2d,
                width,
                height,
                1,
                1,
                reshade::api::format::r32_float,
                1,
                reshade::api::memory_heap::gpu_only,
                reshade::api::resource_usage::unordered_access |
                reshade::api::resource_usage::copy_source |
                reshade::api::resource_usage::copy_dest |
                reshade::api::resource_usage::shader_resource |
                reshade::api::resource_usage::render_target,
                reshade::api::resource_flags::none);

            device->create_resource(desc, nullptr, desc.usage, &out_depth.texture);
        }

        // UAV
        out_ao.uavs.resize(1);
        out_normal.uavs.resize(1);

        for (uint32_t i = 0; i < 1; ++i)
        {
            reshade::api::resource_view_desc view{};
            view.type = reshade::api::resource_view_type::texture_2d;
            view.format = reshade::api::format::r8g8_unorm;
            view.texture.first_level = 0;
            view.texture.level_count = 1;

            reshade::api::resource_view_desc view_normal{};
            view_normal.type = reshade::api::resource_view_type::texture_2d;
            view_normal.format = reshade::api::format::r10g10b10a2_unorm;
            view_normal.texture.first_level = 0;
            view_normal.texture.level_count = 1;

            device->create_resource_view(
                out_ao.texture,
                reshade::api::resource_usage::unordered_access,
                view,
                &out_ao.uavs[i]);

            device->create_resource_view(
                out_normal.texture,
                reshade::api::resource_usage::unordered_access,
                view_normal,
                &out_normal.uavs[i]);
        }

        // SRV
        out_ao.srvs.resize(1);
        out_normal.srvs.resize(1);

        for (uint32_t i = 0; i < 1; ++i)
        {
            reshade::api::resource_view_desc view{};
            view.type = reshade::api::resource_view_type::texture_2d;
            view.format = reshade::api::format::r8g8_unorm;
            view.texture.first_level = 0;
            view.texture.level_count = 1;

            reshade::api::resource_view_desc view_normal{};
            view_normal.type = reshade::api::resource_view_type::texture_2d;
            view_normal.format = reshade::api::format::r10g10b10a2_unorm;
            view_normal.texture.first_level = 0;
            view_normal.texture.level_count = 1;

            device->create_resource_view(
                out_ao.texture,
                reshade::api::resource_usage::shader_resource,
                view,
                &out_ao.srvs[i]);

            device->create_resource_view(
                out_normal.texture,
                reshade::api::resource_usage::shader_resource,
                view_normal,
                &out_normal.srvs[i]);
        }

        // UAV
        out_depth.uavs.resize(1);

        for (uint32_t i = 0; i < 1; ++i)
        {
            reshade::api::resource_view_desc view{};
            view.type = reshade::api::resource_view_type::texture_2d;
            view.format = reshade::api::format::r32_float;
            view.texture.first_level = 0;
            view.texture.level_count = 1;

            device->create_resource_view(
                out_depth.texture,
                reshade::api::resource_usage::unordered_access,
                view,
                &out_depth.uavs[i]);
        }

        // SRV
        out_depth.srvs.resize(1);

        for (uint32_t i = 0; i < 1; ++i)
        {
            reshade::api::resource_view_desc view{};
            view.type = reshade::api::resource_view_type::texture_2d;
            view.format = reshade::api::format::r32_float;
            view.texture.first_level = 0;
            view.texture.level_count = 1;

            device->create_resource_view(
                out_depth.texture,
                reshade::api::resource_usage::shader_resource,
                view,
                &out_depth.srvs[i]);
        }
    }

    void update_descriptor_table(
        reshade::api::device* device,
        const reshade::api::resource_view& accumulated_ao_srv,
        const reshade::api::resource_view& depth_srv,
        const reshade::api::resource_view& normal_srv)
    {
        // Descriptor updates
        reshade::api::descriptor_table_update updates[6]{};

        // Output AO UAV
        updates[0].table = pipeline.descriptor_table;
        updates[0].binding = 0;
        updates[0].array_offset = 0;
        updates[0].count = 1;
        updates[0].type = reshade::api::descriptor_type::texture_unordered_access_view;
        updates[0].descriptors = &out_ao.uavs[0];

        // Depth UAV
        updates[1].table = pipeline.descriptor_table;
        updates[1].binding = 1;
        updates[1].array_offset = 0;
        updates[1].count = 1;
        updates[1].type = reshade::api::descriptor_type::texture_unordered_access_view;
        updates[1].descriptors = &out_depth.uavs[0];

        // Normal UAV
        updates[2].table = pipeline.descriptor_table;
        updates[2].binding = 2;
        updates[2].array_offset = 0;
        updates[2].count = 1;
        updates[2].type = reshade::api::descriptor_type::texture_unordered_access_view;
        updates[2].descriptors = &out_normal.uavs[0];

        // Input AO SRV
        updates[3].table = pipeline.descriptor_table;
        updates[3].binding = 3;
        updates[3].array_offset = 0;
        updates[3].count = 1;
        updates[3].type = reshade::api::descriptor_type::texture_shader_resource_view;
        updates[3].descriptors = &accumulated_ao_srv;

        // Depth Mips SRV
        updates[4].table = pipeline.descriptor_table;
        updates[4].binding = 4;
        updates[4].array_offset = 0;
        updates[4].count = 1;
        updates[4].type = reshade::api::descriptor_type::texture_shader_resource_view;
        updates[4].descriptors = &depth_srv;

        // Normal SRV
        updates[5].table = pipeline.descriptor_table;
        updates[5].binding = 5;
        updates[5].array_offset = 0;
        updates[5].count = 1;
        updates[5].type = reshade::api::descriptor_type::texture_shader_resource_view;
        updates[5].descriptors = &normal_srv;

        device->update_descriptor_tables(6, updates);
    }

    void destroy(reshade::api::device* device)
    {
        out_ao.destroy(device);
        out_depth.destroy(device);
        out_normal.destroy(device);
        pipeline.destroy(device);
    }
};

struct __declspec(uuid("595827c4-19b2-4300-af4d-c6802d6c7636")) DeviceData {
    std::vector<reshade::api::descriptor_table> current_descriptor_tables;
    reshade::api::descriptor_table game_cbuffer_descriptor_table;
  
    XeGTAODepthFilter depthFilter;
    XeGTAOMainPass mainPass;
    XeGTAOTemporalAccumulation temporalPass;
    XeGTAODenoise denoisePass;

    void setup(reshade::api::device* device)
    {
        depthFilter.setup(device);
        mainPass.setup(device);
        temporalPass.setup(device);
        denoisePass.setup(device);
    }

    void create_resources(
        reshade::api::device* device,
        uint32_t width,
        uint32_t height)
    {
        depthFilter.create_resources(device, width, height);
        mainPass.create_resources(device, width, height);
        temporalPass.create_resources(device, width, height);
        denoisePass.create_resources(device, width, height);

        depthFilter.update_descriptor_table(device);
        mainPass.update_descriptor_table(device, depthFilter.working_depth.srvs[0]);
        temporalPass.update_descriptor_table(device, mainPass.working_ao.srvs[0], depthFilter.working_depth.srvs[0], mainPass.working_normal.srvs[0], denoisePass.out_ao.srvs[0], denoisePass.out_depth.srvs[0], denoisePass.out_normal.srvs[0]);
        denoisePass.update_descriptor_table(device, temporalPass.accumulated_ao.srvs[0], depthFilter.working_depth.srvs[0], mainPass.working_normal.srvs[0]);
    }

    void destroy_resources(reshade::api::device* device)
    {
      /*
    auto& depthMip = data->depthFilter.working_depth;
    auto& mainAO = data->mainPass.working_ao;
    auto& temporalAO = data->temporalPass.accumulated_ao;
    auto& denoiseAO = data->denoisePass.out_ao;
    auto& denoiseDepth = data->denoisePass.out_depth;
      */
        depthFilter.working_depth.destroy(device);
        mainPass.working_ao.destroy(device);
        mainPass.working_normal.destroy(device);
        temporalPass.accumulated_ao.destroy(device);
        denoisePass.out_ao.destroy(device);
        denoisePass.out_depth.destroy(device);
        denoisePass.out_normal.destroy(device);
    }

    void destroy(reshade::api::device* device)
    {
        depthFilter.destroy(device);
        mainPass.destroy(device);
        temporalPass.destroy(device);
        denoisePass.destroy(device);
    }
};
#endif

int16_t screen_width = 0;
int16_t screen_height = 0;
uint32_t render_width = 0;
uint32_t render_height = 0;
bool render_res_confirmed = false;
bool gtao_has_drawn = false;
bool gtao_will_draw = false;
bool resource_need_recreate = false;

#ifdef REMOVE_UI
bool isPingInputCandidate = false;
bool isUIDInputCandidate = false;
bool swapchain_drawing = false;

struct DrawIndexedInstancedParams {
    uint32_t index_count;
    uint32_t instance_count;
    uint32_t first_index;
    int32_t vertex_offset;
    uint32_t first_instance;
};

DrawIndexedInstancedParams drawParams;
float use_ping = 1.0f;
float use_uid = 1.0f;
//float ui_aspect = 1.0f;
#endif

#ifdef RESHADE_AO
#ifdef RESHADE_AO_DEBUG
bool hasDepth = false;
#endif
#endif

std::vector<std::string> generateNumberLabels(int start, int end, int step = 1) {
    std::vector<std::string> labels;
    for (int i = start; i <= end; i += step) {
        labels.emplace_back(std::to_string(i));
    }
    return labels;
}

ShaderInjectData shader_injection;

#ifdef REMOVE_UI
bool OnPingDraw(reshade::api::command_list* cmd_list) {
		constexpr uint32_t PING_INDEX_COUNT = 18;
		constexpr uint32_t PING_FIRST_INDEX = 0;
		constexpr int32_t PING_VERTEX_OFFSET = 0;
    isPingInputCandidate = (drawParams.index_count == PING_INDEX_COUNT) && 
							   (drawParams.first_index == PING_FIRST_INDEX) && 
							   (drawParams.vertex_offset == PING_VERTEX_OFFSET);

    shader_injection.ui_disable_flag = isPingInputCandidate && (use_ping == 0.0f) ? 1.0f : 0.0f;
    return true;
	
}

bool OnUIDDraw(reshade::api::command_list* cmd_list) {
    constexpr uint32_t UID_FIRST_INDEX = 18;
		constexpr uint32_t UID_INDEX_COUNT = 100; //min = (2 (ms) + 4 (uid:) + 10 (uid) + (1 to 4 for ping)) * 6 = 102 min, 120 max or (102 || 108 || 114 || 120)
    constexpr int32_t UID_VERTEX_OFFSET = 12;
    isUIDInputCandidate = (drawParams.first_index == UID_FIRST_INDEX) && (drawParams.index_count > UID_INDEX_COUNT) && (drawParams.vertex_offset == UID_VERTEX_OFFSET) && isPingInputCandidate;
    return !(isUIDInputCandidate && (use_uid == 0.0f));
}
#endif

#ifdef RESHADE_AO
bool OnNormalDepthBlit(reshade::api::command_list* cmd_list)
{
    if (!render_res_confirmed) {
#ifdef RESHADE_AO_DEBUG
        reshade::log::message(
            reshade::log::level::info,
            "Checking normal depth blit pass");
#endif

        auto* cmd_list_data = renodx::utils::data::Get<renodx::utils::swapchain::CommandListData>(cmd_list);
        if (cmd_list_data == nullptr) return true;
        if (cmd_list_data->current_render_targets.empty()) return true;

        auto rtv0 = cmd_list_data->current_render_targets[0];
        if (rtv0.handle == 0) return true;

        auto* device = cmd_list->get_device();

        auto current_rtv = device->get_resource_desc(device->get_resource_from_view(rtv0));
        
#ifdef RESHADE_AO_DEBUG
        std::stringstream s;
        s << "Width = " << current_rtv.texture.width;
        s << ", Height = " << current_rtv.texture.height;
        s << ", Format = " << current_rtv.texture.format;
        reshade::log::message(reshade::log::level::info, s.str().c_str());
#endif
	
        if (current_rtv.texture.format == reshade::api::format::r10g10b10a2_typeless) {

#ifdef RESHADE_AO_DEBUG
            reshade::log::message(
                reshade::log::level::info,
                "Got normal depth blit RTV");
#endif

            if (current_rtv.texture.width != render_width || current_rtv.texture.height != render_height) {
                resource_need_recreate = true;
            }
            render_width = current_rtv.texture.width;
            render_height = current_rtv.texture.height;

#ifdef RESHADE_AO_DEBUG
            reshade::log::message(
                reshade::log::level::debug,
                std::format("Render - width:{} height:{}", static_cast<float>(render_width), static_cast<float>(render_height)).c_str());
#endif

            render_res_confirmed = true;
			gtao_will_draw = true;
        }
    }
    return true;
}

bool OnGTAODepthFilterDispatch(reshade::api::command_list* cmd_list)
{
    auto* device = cmd_list->get_device();
    auto* data = renodx::utils::data::Get<DeviceData>(device);

    if (data == nullptr)
        return true;

    // ---------------------------------------------------------
    // Resource validation / recreation
    // ---------------------------------------------------------
    auto& depthMip = data->depthFilter.working_depth;
    auto& mainAO = data->mainPass.working_ao;
    auto& temporalAO = data->temporalPass.accumulated_ao;
    auto& denoiseAO = data->denoisePass.out_ao;
    auto& denoiseDepth = data->denoisePass.out_depth;

    if (resource_need_recreate)
    {
        data->destroy_resources(device);
        data->create_resources(device, render_width, render_height);
        resource_need_recreate = false;

        reshade::log::message(
            reshade::log::level::info,
            "Recreating resources");
    }
    else if (depthMip.texture.handle == 0)
    {
        reshade::log::message(
            reshade::log::level::info,
            "Resources handles are 0, creating resources");

        data->create_resources(device, render_width, render_height);
    }
#ifdef RESHADE_AO_DEBUG
    hasDepth = true;
#endif

    // ---------------------------------------------------------
    // Compute dispatch
    // ---------------------------------------------------------
    cmd_list->bind_pipeline(
        reshade::api::pipeline_stage::all_compute,
        data->depthFilter.pipeline.pipeline);

    reshade::api::descriptor_table descriptor_tables[3] = {
        data->current_descriptor_tables[0],
        data->current_descriptor_tables[1],
        data->depthFilter.pipeline.descriptor_table
    };

    // Store the cbuffer table for later use
    data->game_cbuffer_descriptor_table = data->current_descriptor_tables[1];

    cmd_list->bind_descriptor_tables(
        reshade::api::shader_stage::all_compute,
        data->depthFilter.pipeline.layout,
        0,
        3,
        descriptor_tables);

    // Batched barrier
    {
        reshade::api::resource resources[] = {
            depthMip.texture
        };

        reshade::api::resource_usage old_states[] = {
            reshade::api::resource_usage::unordered_access |
            reshade::api::resource_usage::shader_resource
        };

        reshade::api::resource_usage new_states[] = {
            reshade::api::resource_usage::unordered_access
        };

        cmd_list->barrier(1, resources, old_states, new_states);
    }

    cmd_list->dispatch(
        (render_width + 16 - 1) / 16,
        (render_height + 16 - 1) / 16,
        1);

    return false;
}

bool OnGTAOMainDispatch(reshade::api::command_list* cmd_list)
{
    auto* device = cmd_list->get_device();
    auto* data = renodx::utils::data::Get<DeviceData>(device);

    if (data == nullptr)
        return true;

    // ---------------------------------------------------------
    // Resource validation / recreation
    // ---------------------------------------------------------
    auto& depthMip = data->depthFilter.working_depth;
    auto& workingAO = data->mainPass.working_ao;
    auto& workingNormal = data->mainPass.working_normal;

    // ---------------------------------------------------------
    // Compute dispatch
    // ---------------------------------------------------------
    cmd_list->bind_pipeline(
        reshade::api::pipeline_stage::all_compute,
        data->mainPass.pipeline.pipeline);

    reshade::api::descriptor_table descriptor_tables[3] = {
        data->current_descriptor_tables[0],
        data->current_descriptor_tables[1],
        data->mainPass.pipeline.descriptor_table
    };

    cmd_list->bind_descriptor_tables(
        reshade::api::shader_stage::all_compute,
        data->mainPass.pipeline.layout,
        0,
        3,
        descriptor_tables);

    // Batched barriers
    {
        reshade::api::resource resources[] = {
            depthMip.texture,
            workingAO.texture,
            workingNormal.texture
        };

        reshade::api::resource_usage old_states[] = {
            reshade::api::resource_usage::unordered_access |
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::shader_resource
        };

        reshade::api::resource_usage new_states[] = {
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::unordered_access |
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::unordered_access |
            reshade::api::resource_usage::shader_resource
        };

        cmd_list->barrier(3, resources, old_states, new_states);
    }

    cmd_list->dispatch(
        (render_width + 8 - 1) / 8,
        (render_height + 8 - 1) / 8,
        1);

    return false;
}

bool OnGTAOTemporalDispatch(reshade::api::command_list* cmd_list)
{
    auto* device = cmd_list->get_device();
    auto* data = renodx::utils::data::Get<DeviceData>(device);

    if (data == nullptr)
        return true;

    // ---------------------------------------------------------
    // Resource validation / recreation
    // ---------------------------------------------------------
    auto& depthMip = data->depthFilter.working_depth;
    auto& workingAO = data->mainPass.working_ao;
    auto& workingNormal = data->mainPass.working_normal;
    auto& temporalAO = data->temporalPass.accumulated_ao;
    auto& prevAO = data->denoisePass.out_ao;
    auto& prevDepth = data->denoisePass.out_depth;
    auto& prevNormal = data->denoisePass.out_normal;

    // ---------------------------------------------------------
    // Compute dispatch
    // ---------------------------------------------------------
    {
        cmd_list->bind_pipeline(
            reshade::api::pipeline_stage::all_compute,
            data->temporalPass.pipeline.pipeline);

        reshade::api::descriptor_table descriptor_tables[3] = {
            data->current_descriptor_tables[0],
            data->game_cbuffer_descriptor_table,
            data->temporalPass.pipeline.descriptor_table
        };

        cmd_list->bind_descriptor_tables(
            reshade::api::shader_stage::all_compute,
            data->temporalPass.pipeline.layout,
            0,
            3,
            descriptor_tables);

    // Batched barriers
    {
        reshade::api::resource resources[] = {
            workingAO.texture,
            prevAO.texture,
            prevDepth.texture,
            workingNormal.texture,
            prevNormal.texture,
            temporalAO.texture
        };

        reshade::api::resource_usage old_states[] = {
            reshade::api::resource_usage::unordered_access |
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::unordered_access |
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::unordered_access |
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::unordered_access |
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::unordered_access |
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::shader_resource
        };

        reshade::api::resource_usage new_states[] = {
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::unordered_access |
            reshade::api::resource_usage::shader_resource
        };

        cmd_list->barrier(6, resources, old_states, new_states);
    }

        cmd_list->dispatch(
            (render_width + 8 - 1) / 8,
            (render_height + 8 - 1) / 8,
            1);
      }

    return false;
}

bool OnGTAOUpscaleDispatch(reshade::api::command_list* cmd_list)
{
    auto* device = cmd_list->get_device();
    auto* data = renodx::utils::data::Get<DeviceData>(device);

    if (data == nullptr)
        return true;

    // ---------------------------------------------------------
    // Resource validation / recreation
    // ---------------------------------------------------------
    auto& depthMip = data->depthFilter.working_depth;
    auto& workingAO = data->mainPass.working_ao;
    auto& workingNormal = data->mainPass.working_normal;
    auto& temporalAO = data->temporalPass.accumulated_ao;
    auto& prevAO = data->denoisePass.out_ao;
    auto& prevDepth = data->denoisePass.out_depth;
    auto& prevNormal = data->denoisePass.out_normal;

    // ---------------------------------------------------------
    // Compute dispatch
    // ---------------------------------------------------------
    {
        cmd_list->bind_pipeline(
            reshade::api::pipeline_stage::all_compute,
            data->denoisePass.pipeline.pipeline);

        reshade::api::descriptor_table descriptor_tables[3] = {
            data->current_descriptor_tables[0],
            data->game_cbuffer_descriptor_table,
            data->denoisePass.pipeline.descriptor_table
        };

        cmd_list->bind_descriptor_tables(
            reshade::api::shader_stage::all_compute,
            data->denoisePass.pipeline.layout,
            0,
            3,
            descriptor_tables);

    // Batched barriers
    {
        reshade::api::resource resources[] = {
            prevAO.texture,
            prevDepth.texture,
            prevNormal.texture,
            temporalAO.texture,
            workingNormal.texture
        };

        reshade::api::resource_usage old_states[] = {
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::unordered_access |
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::unordered_access |
            reshade::api::resource_usage::shader_resource
        };

        reshade::api::resource_usage new_states[] = {
            reshade::api::resource_usage::unordered_access |
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::unordered_access |
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::unordered_access |
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::shader_resource,
            reshade::api::resource_usage::shader_resource
        };

        cmd_list->barrier(5, resources, old_states, new_states);
    }
        cmd_list->dispatch(
            (render_width + 8 - 1) / 8,
            (render_height + 8 - 1) / 8,
            1);
    }
	
	gtao_has_drawn = true;
#ifdef RESHADE_AO_DEBUG
    // ---------------------------------------------------------
    // Post-effects
    // ---------------------------------------------------------
    auto* swap_data =
        renodx::utils::data::Get<renodx::utils::swapchain::DeviceData>(device);

    if (swap_data == nullptr)
        return true;

    const std::shared_lock lock(swap_data->mutex);

    for (auto* runtime : swap_data->effect_runtimes)
    {
        runtime->set_effects_state(true);
        runtime->render_effects(
            cmd_list,
            depthMip.srvs[0],
            depthMip.srvs[0]);
    }
#endif

    return false;
}
#endif

renodx::mods::shader::CustomShaders custom_shaders = {

#ifdef REMOVE_UI
	{0xEA9EED6C, {
			 .crc32 = 0xEA9EED6C,
       .code = __0xEA9EED6C,
			 .on_draw = &OnPingDraw,
       .on_drawn = [](auto* cmd_list) { shader_injection.ui_disable_flag = 0.0f; return true; },
		 },
	},
  {0x92BB9EA9, {
			 .crc32 = 0x92BB9EA9,
			 .on_draw = &OnUIDDraw,
		 },
	},
#endif
#ifdef RESHADE_AO
	{0xC14B0925, {
			 .crc32 = 0xC14B0925,
			 .on_draw = &OnNormalDepthBlit,
		 },
	},
	{0x71C92F19, {
			 .crc32 = 0x71C92F19,
			 //.code = __0x71C92F19,
			 .on_draw = &OnGTAODepthFilterDispatch,
		 },
	},
	{0x65236CFD, {
			 .crc32 = 0x65236CFD,
			 //.code = __0x65236CFD,
			 .on_draw = &OnGTAOMainDispatch,
		 },
	},
	{0xF1E4A910, {
			 .crc32 = 0xF1E4A910,
			 //.code = __0xF1E4A910,
			 .on_draw = &OnGTAOTemporalDispatch,
		 },
	},
  {0x820102A4, {
			 .crc32 = 0x820102A4,
			 //.code = __0x820102A4,
			 .on_draw = [](auto* cmd_list) { return false; },
		 },
	},
  {0x3F1D52C5, {
			 .crc32 = 0x3F1D52C5,
			 //.code = __0x3F1D52C5,
			 .on_draw = [](auto* cmd_list) { return false; },
		 },
	},
	{0x21E2F7BD, {
			 .crc32 = 0x21E2F7BD,
			 //.code = __0x21E2F7BD,
			 .on_draw = &OnGTAOUpscaleDispatch,
		 },
	},
#endif
	__ALL_CUSTOM_SHADERS,
};

const std::string build_date = __DATE__;
const std::string build_time = __TIME__;

renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .key = "AORadius",
        .binding = &shader_injection.ao_radius,
        .default_value = 4.0f,
        .label = "AO Radius",
        .section = "Lighting",
        .tooltip = "",
        .min = 0.f,
        .max = 16.f,
        .format = "%.2f",
    },
    new renodx::utils::settings::Setting{
        .key = "AORadiusScale",
        .binding = &shader_injection.ao_radius_scale,
        .default_value = 1.0f,
        .label = "AO Radius Scale",
        .section = "Lighting",
        .tooltip = "",
        .min = 0.f,
        .max = 16.f,
        .format = "%.2f",
    },
    new renodx::utils::settings::Setting{
        .key = "AOFalloff",
        .binding = &shader_injection.ao_falloff_range,
        .default_value = 1.0f,
        .label = "AO Falloff Range",
        .section = "Lighting",
        .tooltip = "",
        .min = 0.f,
        .max = 1.f,
        .format = "%.2f",
    },
    new renodx::utils::settings::Setting{
        .key = "AODistPower",
        .binding = &shader_injection.ao_distribution_power,
        .default_value = 1.0f,
        .label = "AO Distribution Power",
        .section = "Lighting",
        .tooltip = "",
        .min = 0.f,
        .max = 16.f,
        .format = "%.2f",
    },
    new renodx::utils::settings::Setting{
        .key = "AOThinOccluder",
        .binding = &shader_injection.ao_thin_occluder,
        .default_value = 0.0f,
        .label = "AO Thin Occluder Compensation",
        .section = "Lighting",
        .tooltip = "",
        .min = 0.f,
        .max = 16.f,
        .format = "%.2f",
    },
    new renodx::utils::settings::Setting{
        .key = "AOGamma",
        .binding = &shader_injection.ao_gamma,
        .default_value = 2.2f,
        .label = "AO Gamma",
        .section = "Lighting",
        .tooltip = "",
        .min = 0.f,
        .max = 16.f,
        .format = "%.2f",
    },
    new renodx::utils::settings::Setting{
        .key = "AOMipBias",
        .binding = &shader_injection.ao_mip_bias,
        .default_value = 0.0f,
        .label = "AO MipBias",
        .section = "Lighting",
        .tooltip = "",
        .min = 0.f,
        .max = 16.f,
        .format = "%.2f",
    },
    new renodx::utils::settings::Setting{
        .key = "AODirCount",
        .binding = &shader_injection.ao_direction_count,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 3.0f,
        .label = "AO Direction Count",
        .section = "Lighting",
        .tooltip = "",
        .labels = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16"},
        .min = 0.f,
        .max = 16.0f,
    },
    new renodx::utils::settings::Setting{
        .key = "AOStepCount",
        .binding = &shader_injection.ao_step_count,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 3.0f,
        .label = "AO Step Count",
        .section = "Lighting",
        .tooltip = "",
        .labels = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16"},
        .min = 0.f,
        .max = 16.0f,
    },
    new renodx::utils::settings::Setting{
        .key = "AONrmAtt",
        .binding = &shader_injection.ao_normal_attenuation,
        .default_value = 0.05f,
        .label = "AO Normal Attenuation",
        .section = "Lighting",
        .tooltip = "",
        .min = 0.f,
        .max = 1.f,
        .format = "%.3f",
    },
    new renodx::utils::settings::Setting{
		.key = "AOBitmask",
        .binding = &shader_injection.ao_bitmask,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 0.0f,
        .label = "AO Visibility Bitmask",
        .section = "Lighting",
        .tooltip = "",
        .labels = {"Off", "On"},
    },
    new renodx::utils::settings::Setting{
        .key = "AOThickness",
        .binding = &shader_injection.ao_thickness,
        .default_value = 1.0f,
        .label = "AO Thickness",
        .section = "Lighting",
        .tooltip = "",
        .min = 0.f,
        .max = 16.f,
        .format = "%.2f",
    },
    new renodx::utils::settings::Setting{
        .key = "AODenoiser",
        .binding = &shader_injection.ao_denoiser_blur_beta,
        .default_value = 20.0f,
        .label = "AO Denoiser Blur Beta",
        .section = "Lighting",
        .tooltip = "",
        .min = 0.f,
        .max = 1000.f,
        .format = "%.2f",
    },
    new renodx::utils::settings::Setting{
        .key = "SSRMip",
        .binding = &shader_injection.ssr_mip_threshold,
        .default_value = 0.25f,
        .label = "SSR Mipmap Threshold",
        .section = "Reflections",
        .tooltip = "",
        .min = 0.f,
        .max = 16.f,
        .format = "%.2f",
    },
	new renodx::utils::settings::Setting{
        .key = "SSRStepScale",
        .binding = &shader_injection.ssr_step_scale,
        .default_value = 1.0f,
        .label = "SSR Step Count Scale",
        .section = "Reflections",
        .tooltip = "",
        .min = 0.f,
        .max = 16.f,
        .format = "%.2f",
    },
	new renodx::utils::settings::Setting{
        .key = "SSRMaxStep",
        .binding = &shader_injection.ssr_step_max,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 32.0f,
        .label = "SSR Min Step Count",
        .section = "Reflections",
        .tooltip = "",
        .labels = generateNumberLabels(0, 256, 1),
        .min = 1.f,
        .max = 256.0f,
    },
#ifdef REMOVE_UI
	new renodx::utils::settings::Setting{
		.key = "UsePing",
        .binding = &use_ping,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.0f,
        .label = "Show Ping Indicator",
        .section = "UI",
        .tooltip = "",
        .labels = {"Off", "On"},
    },
    new renodx::utils::settings::Setting{
		.key = "UseUID",
        .binding = &use_uid,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.0f,
        .label = "Show Ping and UID",
        .section = "UI",
        .tooltip = "",
        .labels = {"Off", "On"},
    },
#endif
    new renodx::utils::settings::Setting{
        .key = "FPSLimit",
        .binding = &renodx::utils::swapchain::fps_limit,
        .default_value = 0.f,
        .label = "FPS Limit",
        .min = 0.f,
        .max = 480.f,
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Mod by miru.",
        .section = "About",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "RenoDX Framework by ShortFuse.",
        .section = "About",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "This build was compiled on " + build_date + " at " + build_time + ".",
        .section = "About",
    }
};

void OnInitSwapchain(reshade::api::swapchain* swapchain, bool resize) {
	auto* device = swapchain->get_device();
	//auto* data = renodx::utils::data::Get<renodx::mods::swapchain::DeviceData>(device);
	//if (!data) return;

	auto bb = device->get_resource_desc(swapchain->get_current_back_buffer());
	if (bb.type == reshade::api::resource_type::unknown) return;
    
    if (bb.texture.width != screen_width || bb.texture.height != screen_height) {
        resource_need_recreate = true;
    }

    screen_width = bb.texture.width;
    screen_height = bb.texture.height;
    shader_injection.ui_aspect_ratio = static_cast<float>(bb.texture.height) / static_cast<float>(bb.texture.width);
	return;
}

#ifdef REMOVE_UI
bool OnDrawIndexed(
    reshade::api::command_list* cmd_list,
    uint32_t index_count,
    uint32_t instance_count,
    uint32_t first_index,
    int32_t vertex_offset,
    uint32_t first_instance) {
		
	if (!swapchain_drawing)
	{
		if (renodx::utils::swapchain::HasBackBufferRenderTarget(cmd_list))
		{
			swapchain_drawing = true;
		}
	}
	
	if (swapchain_drawing)
	{
		drawParams.index_count = index_count;
		drawParams.instance_count = instance_count;
		drawParams.first_index = first_index;
		drawParams.vertex_offset = vertex_offset;
		drawParams.first_instance = first_instance;
	}

    return false;
}
#endif

void OnPresent(
    reshade::api::command_queue* queue,
    reshade::api::swapchain* swapchain,
    const reshade::api::rect* source_rect,
    const reshade::api::rect* dest_rect,
    uint32_t dirty_rect_count,
    const reshade::api::rect* dirty_rects) {
#ifdef REMOVE_UI
	isPingInputCandidate = false;
	isUIDInputCandidate = false;
	drawParams = {0, 0, 0, 0, 0};
	swapchain_drawing = false;
#endif
#ifdef RESHADE_AO
#ifdef RESHADE_AO_DEBUG
  if (hasDepth) {
      hasDepth = false;
  }
#endif
  if (render_res_confirmed) {
      render_res_confirmed = false;
  }
  if (gtao_has_drawn) {
	  gtao_has_drawn = false;
  }
  if (gtao_will_draw) {
	  gtao_will_draw = false;
  }
#endif
	
}


#ifdef RESHADE_AO
void OnInitDevice(reshade::api::device* device) {
    if (device->get_api() == reshade::api::device_api::vulkan)
    {
        renodx::utils::data::Create<DeviceData>(device);
        auto* data = renodx::utils::data::Get<DeviceData>(device);
        if (data) {
            data->current_descriptor_tables.clear();
            data->game_cbuffer_descriptor_table = {0};
            data->setup(device);
        }
    }
}

void OnDestroyDevice(reshade::api::device* device) {
    if (device->get_api() == reshade::api::device_api::vulkan)
    {
        auto* data = renodx::utils::data::Get<DeviceData>(device);
        if (data) {
            data->current_descriptor_tables.clear();
            data->game_cbuffer_descriptor_table = {0};
            data->destroy(device);
        }
        renodx::utils::data::Delete<DeviceData>(device);
    }
}

void OnBindDescriptorTables(
    reshade::api::command_list* cmd_list,
    reshade::api::shader_stage stages,
    reshade::api::pipeline_layout layout,
    uint32_t first,
    uint32_t count,
    const reshade::api::descriptor_table* tables) {
		
	if (!gtao_has_drawn && gtao_will_draw)
	{
		auto* device = cmd_list->get_device();
		auto* data = renodx::utils::data::Get<DeviceData>(device);
		if (data == nullptr) return;

		// Resize if needed
		if (data->current_descriptor_tables.size() < first + count) {
			data->current_descriptor_tables.resize(first + count);
		}
		// Copy the descriptor tables
		for (uint32_t i = 0; i < count; ++i) {
			data->current_descriptor_tables[first + i] = tables[i];
		}
	}
}

#ifdef RESHADE_AO_DEBUG
void OnBeginRenderEffects(reshade::api::effect_runtime *runtime, reshade::api::command_list *cmd_list, reshade::api::resource_view rtv, reshade::api::resource_view rtv_srgb) {
    auto* device = cmd_list->get_device();
	
    auto* renodx_device_data = renodx::utils::data::Get<renodx::utils::swapchain::DeviceData>(device);
    if (renodx_device_data == nullptr) return;
    const std::shared_lock lock(renodx_device_data->mutex);

    auto* data = renodx::utils::data::Get<DeviceData>(device);
    if (data == nullptr) return;

    if (!hasDepth) {
        for (auto* runtime : renodx_device_data->effect_runtimes) {
            if (runtime == nullptr) continue;

            reshade::api::resource_view empty_view = {0u};
            runtime->update_texture_bindings("DEPTH", empty_view, empty_view);
            runtime->update_texture_bindings("WORKING_AO", empty_view, empty_view);
            runtime->update_texture_bindings("WORKING_NORMAL", empty_view, empty_view);
            runtime->update_texture_bindings("TEMPORAL_AO", empty_view, empty_view);
            runtime->update_texture_bindings("OUT_AO", empty_view, empty_view);
            runtime->update_texture_bindings("OUT_DEPTH", empty_view, empty_view);
            reshade::log::message(reshade::log::level::info, "uav handle is 0, binding empty view");
        }
        runtime->set_effects_state(false);
        return;
    }

    auto& depthMip = data->depthFilter.working_depth;
    auto& workingAO = data->mainPass.working_ao;
    auto& workingNormal = data->mainPass.working_normal;
    auto& prevAO = data->denoisePass.out_ao;
    auto& denoiseDepth = data->denoisePass.out_depth;
    auto& temporalAO = data->temporalPass.accumulated_ao;

    for (auto* runtime : renodx_device_data->effect_runtimes) {
        if (runtime == nullptr) continue;

        if (depthMip.srvs[0].handle != 0) {
            runtime->update_texture_bindings("DEPTH", depthMip.srvs[0], depthMip.srvs[0]);
            runtime->update_texture_bindings("WORKING_AO", workingAO.srvs[0], workingAO.srvs[0]);
            runtime->update_texture_bindings("WORKING_NORMAL", workingNormal.srvs[0], workingNormal.srvs[0]);
            runtime->update_texture_bindings("TEMPORAL_AO", temporalAO.srvs[0], temporalAO.srvs[0]);
            runtime->update_texture_bindings("OUT_AO", prevAO.srvs[0], prevAO.srvs[0]);
            runtime->update_texture_bindings("OUT_DEPTH", denoiseDepth.srvs[0], denoiseDepth.srvs[0]);
        }
        else
        {
          reshade::api::resource_view empty_view = {0u};
          runtime->update_texture_bindings("DEPTH", empty_view, empty_view);
          runtime->update_texture_bindings("WORKING_AO", empty_view, empty_view);
          runtime->update_texture_bindings("WORKING_NORMAL", empty_view, empty_view);
          runtime->update_texture_bindings("TEMPORAL_AO", empty_view, empty_view);
          runtime->update_texture_bindings("OUT_AO", empty_view, empty_view);
          runtime->update_texture_bindings("OUT_DEPTH", empty_view, empty_view);
          reshade::log::message(reshade::log::level::info, "uav handle is 0, binding empty view");
        }
    }

    hasDepth = false;
}
#endif
#endif

bool initialized = false;

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "AO Endfield";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "AO Intensity tweak for Endfield.";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID lpv_reserved) {
  auto use_resource_view_cloning = false;
  
  auto common_aspect_ratio_tolerance = 0.00001f;
  
  const auto view_upgrades = renodx::utils::resource::VIEW_UPGRADES_RGBA16F;
  
  const renodx::utils::resource::ResourceUpgradeInfo::Dimensions min_dimensions = {
	  .width = renodx::utils::resource::ResourceUpgradeInfo::ANY,
	  .height = renodx::utils::resource::ResourceUpgradeInfo::ANY,
	  .depth = renodx::utils::resource::ResourceUpgradeInfo::ANY,
  };
  
  renodx::utils::resource::ResourceUpgradeInfo::Dimensions dimensions = {
	  .width = renodx::utils::resource::ResourceUpgradeInfo::BACK_BUFFER,
	  .height = renodx::utils::resource::ResourceUpgradeInfo::BACK_BUFFER,
	  .depth = renodx::utils::resource::ResourceUpgradeInfo::BACK_BUFFER,
  };
  

  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

      renodx::utils::settings::use_presets = false;
      renodx::mods::swapchain::target_format = reshade::api::format::b8g8r8a8_unorm;
      renodx::mods::swapchain::target_color_space = reshade::api::color_space::srgb_nonlinear;
      renodx::mods::swapchain::set_color_space = false;

      // Always set to true for Vulkan
      renodx::mods::shader::allow_multiple_push_constants = true;
	  renodx::mods::shader::use_pipeline_layout_cloning = false;
      renodx::mods::swapchain::use_resource_cloning = false;

      renodx::mods::shader::expand_existing_constant_buffer = false;
	  
	  renodx::utils::descriptor::trace_descriptor_tables = false;  // RIP FPS

      renodx::mods::shader::minimum_constant_buffer_stages = reshade::api::shader_stage::pixel | reshade::api::shader_stage::compute;
	  
	  reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
	  reshade::register_event<reshade::addon_event::present>(OnPresent);
#ifdef REMOVE_UI
	  reshade::register_event<reshade::addon_event::draw_indexed>(OnDrawIndexed);
#endif
	  
#ifdef RESHADE_AO
      reshade::register_event<reshade::addon_event::init_device>(OnInitDevice);
      reshade::register_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
      reshade::register_event<reshade::addon_event::bind_descriptor_tables>(OnBindDescriptorTables);
#ifdef RESHADE_AO_DEBUG
      reshade::register_event<reshade::addon_event::reshade_begin_effects>(OnBeginRenderEffects);
#endif
#endif
      if (!initialized) {
        // renodx::utils::random::binds.push_back(&shader_injection.swap_chain_output_dither_seed);
        initialized = true;
      }

      break;
    case DLL_PROCESS_DETACH:
	  reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
	  reshade::unregister_event<reshade::addon_event::present>(OnPresent);
#ifdef REMOVE_UI
	  reshade::unregister_event<reshade::addon_event::draw_indexed>(OnDrawIndexed);
#endif

#ifdef RESHADE_AO
      reshade::unregister_event<reshade::addon_event::init_device>(OnInitDevice);
      reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
    reshade::unregister_event<reshade::addon_event::bind_descriptor_tables>(OnBindDescriptorTables);
#ifdef RESHADE_AO_DEBUG
    reshade::unregister_event<reshade::addon_event::reshade_begin_effects>(OnBeginRenderEffects);
#endif


#endif      
	
      reshade::unregister_addon(h_module);
      break;
  }

  renodx::utils::settings::Use(fdw_reason, &settings);
#ifdef RESHADE_AO_DEBUG
  renodx::utils::pipeline_layout::Use(fdw_reason);
  renodx::utils::swapchain::Use(fdw_reason);
  renodx::utils::shader::Use(fdw_reason);
  renodx::utils::descriptor::Use(fdw_reason);
#endif
  //renodx::mods::swapchain::Use(fdw_reason);
  renodx::utils::swapchain::Use(fdw_reason);
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);

  return TRUE;
}
