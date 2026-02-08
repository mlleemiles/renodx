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
struct __declspec(uuid("595827c4-19b2-4300-af4d-c6802d6c7636")) DeviceData {
  std::vector<reshade::api::descriptor_table> current_descriptor_tables;

  reshade::api::pipeline xeGTAO_depth_filter_pipeline{0};
  reshade::api::pipeline_subobject xeGTAO_depth_filter_pipeline_subobjects[1]{};
  reshade::api::shader_desc xeGTAO_depth_filter_shader{};
  reshade::api::pipeline_layout xeGTAO_depth_filter_pipeline_layout{0};

  reshade::api::resource_desc xeGTAO_depth_mip_tex_desc{};
  reshade::api::resource xeGTAO_depth_mip_texture;
  reshade::api::resource_view xeGTAO_depth_mip_uav[5]{};
  reshade::api::resource_view xeGTAO_depth_mip_srv[5]{};
  reshade::api::descriptor_table xeGTAO_depth_mip_descriptor_table{0};

  void setup_xeGTAO_depth_filter(reshade::api::device* device) {
    xeGTAO_depth_filter_shader.code = __0x71C82F19.data();
    xeGTAO_depth_filter_shader.code_size = __0x71C82F19.size();
    xeGTAO_depth_filter_pipeline_subobjects[0].type = reshade::api::pipeline_subobject_type::compute_shader;
    xeGTAO_depth_filter_pipeline_subobjects[0].count = 1;
    xeGTAO_depth_filter_pipeline_subobjects[0].data = &xeGTAO_depth_filter_shader;

    reshade::api::pipeline_layout_param xeGTAO_depth_filter_pipeline_layout_params[3]{};
    xeGTAO_depth_filter_pipeline_layout_params[0].type = reshade::api::pipeline_layout_param_type::descriptor_table;
    xeGTAO_depth_filter_pipeline_layout_params[0].descriptor_table.count = 7;
    xeGTAO_depth_filter_pipeline_layout_params[1].type = reshade::api::pipeline_layout_param_type::descriptor_table;
    xeGTAO_depth_filter_pipeline_layout_params[1].descriptor_table.count = 2;
    xeGTAO_depth_filter_pipeline_layout_params[2].type = reshade::api::pipeline_layout_param_type::descriptor_table;
    xeGTAO_depth_filter_pipeline_layout_params[2].descriptor_table.count = 5;

    reshade::api::descriptor_range table0_ranges[7];

    for (uint32_t i = 0; i < 5; ++i) {
        table0_ranges[i] = {
            .binding = i,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_unordered_access_view
        };
    }
    table0_ranges[5] = {
        .binding = 5,
        .dx_register_index = 0,
        .dx_register_space = 0,
        .count = 1,
        .visibility = reshade::api::shader_stage::compute,
        .array_size = 1,
        .type = reshade::api::descriptor_type::texture_shader_resource_view
    };
    table0_ranges[6] = {
        .binding = 6,
        .dx_register_index = 0,
        .dx_register_space = 0,
        .count = 1,
        .visibility = reshade::api::shader_stage::compute,
        .array_size = 1,
        .type = reshade::api::descriptor_type::sampler
    };

    reshade::api::descriptor_range table1_ranges[2];

    for (uint32_t i = 0; i < 2; ++i) {
        table1_ranges[i] = {
            .binding = i,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::constant_buffer
        };
    }

    reshade::api::descriptor_range table2_ranges[5];

    for (uint32_t i = 0; i < 5; ++i) {
        table2_ranges[i] = {
            .binding = i,
            .dx_register_index = 0,
            .dx_register_space = 0,
            .count = 1,
            .visibility = reshade::api::shader_stage::compute,
            .array_size = 1,
            .type = reshade::api::descriptor_type::texture_unordered_access_view
        };
    }

    xeGTAO_depth_filter_pipeline_layout_params[0] =
        reshade::api::pipeline_layout_param(7, table0_ranges);

    xeGTAO_depth_filter_pipeline_layout_params[1] =
        reshade::api::pipeline_layout_param(2, table1_ranges);

    xeGTAO_depth_filter_pipeline_layout_params[2] =
        reshade::api::pipeline_layout_param(5, table2_ranges);

    bool create_pipeline_layout_result = device->create_pipeline_layout(3, xeGTAO_depth_filter_pipeline_layout_params, &xeGTAO_depth_filter_pipeline_layout);
    if (!create_pipeline_layout_result) {
      reshade::log::message(reshade::log::level::warning, "utils::render::RenderPass(create_pipeline_layout failed)");
      assert(create_pipeline_layout_result != false);
    }

    bool create_pipeline_result = device->create_pipeline(xeGTAO_depth_filter_pipeline_layout, 1, xeGTAO_depth_filter_pipeline_subobjects, &xeGTAO_depth_filter_pipeline);
    if (!create_pipeline_result) {
      reshade::log::message(reshade::log::level::warning, "utils::render::RenderPass(create_pipeline failed)");
      assert(create_pipeline_result != false);
    }

    bool allocate_descriptor_table_result = device->allocate_descriptor_table(xeGTAO_depth_filter_pipeline_layout, 2, &xeGTAO_depth_mip_descriptor_table);
    if (!allocate_descriptor_table_result) {
      reshade::log::message(reshade::log::level::warning, "utils::render::RenderPass(allocate_descriptor_table failed)");
      assert(allocate_descriptor_table_result != false);
    }
    reshade::log::message(reshade::log::level::info, "Logging created layout");
    renodx::utils::trace::internal::LogLayout(3, xeGTAO_depth_filter_pipeline_layout_params, xeGTAO_depth_filter_pipeline_layout);
  }

  void destroy_xeGTAO_depth_filter(reshade::api::device* device) {
    if (xeGTAO_depth_filter_pipeline.handle != 0) {
      device->destroy_pipeline(xeGTAO_depth_filter_pipeline);
      xeGTAO_depth_filter_pipeline = {0};
    }

    if (xeGTAO_depth_mip_descriptor_table.handle != 0) {
      device->free_descriptor_table(xeGTAO_depth_mip_descriptor_table);
      xeGTAO_depth_mip_descriptor_table = {0};
    }

    if (xeGTAO_depth_filter_pipeline_layout.handle != 0) {
      device->destroy_pipeline_layout(xeGTAO_depth_filter_pipeline_layout);
      xeGTAO_depth_filter_pipeline_layout = {0};
    }
  }

  uint32_t GetMaxMipCount(uint32_t width, uint32_t height)
  {
      uint32_t size = std::max(width, height);
      return 32 - std::countl_zero(size);
  }

  void create_resources(reshade::api::device* device, uint32_t width = 1, uint32_t height = 1) {
    xeGTAO_depth_mip_tex_desc = reshade::api::resource_desc(
        reshade::api::resource_type::texture_2d, // type
        width,                                    // width
        height,                                   // height
        1,                                        // depth_or_layers
        GetMaxMipCount(width, height),            // mip levels
        reshade::api::format::r32_float,         // format
        1,                                        // samples
        reshade::api::memory_heap::gpu_only,     // heap
        reshade::api::resource_usage::unordered_access |
        reshade::api::resource_usage::copy_source |
        reshade::api::resource_usage::copy_dest |
        reshade::api::resource_usage::shader_resource |
        reshade::api::resource_usage::render_target, // usage
        reshade::api::resource_flags::none
    );

    reshade::log::message(
        reshade::log::level::debug,
        std::format("Dimension - width:{} height:{}", static_cast<float>(width), static_cast<float>(height)).c_str());

    bool create_resource_result = device->create_resource(
        xeGTAO_depth_mip_tex_desc,
        nullptr,
        reshade::api::resource_usage::unordered_access |
        reshade::api::resource_usage::copy_source |
        reshade::api::resource_usage::copy_dest |
        reshade::api::resource_usage::shader_resource |
        reshade::api::resource_usage::render_target,
        &xeGTAO_depth_mip_texture
    );
    if (!create_resource_result) {
      reshade::log::message(reshade::log::level::warning, "utils::render::RenderPass(create_resource failed)");
      assert(create_resource_result != false);
    }

    for (uint32_t i = 0; i < 5; ++i)
    {
        reshade::api::resource_view_desc view_desc = {};
        view_desc.type = reshade::api::resource_view_type::texture_2d;
        view_desc.format = reshade::api::format::r32_float;

        view_desc.texture.first_level = i;
        view_desc.texture.level_count = 1;

        bool create_resource_view_result = device->create_resource_view(
            xeGTAO_depth_mip_texture,
            reshade::api::resource_usage::unordered_access,
            view_desc,
            &xeGTAO_depth_mip_uav[i]
        );
        if (!create_resource_view_result) {
          reshade::log::message(reshade::log::level::warning, "utils::render::RenderPass(create_resource_view failed)");
          assert(create_resource_view_result != false);
        }

        create_resource_view_result = device->create_resource_view(
            xeGTAO_depth_mip_texture,
            reshade::api::resource_usage::shader_resource,
            view_desc,
            &xeGTAO_depth_mip_srv[i]
        );
        if (!create_resource_view_result) {
          reshade::log::message(reshade::log::level::warning, "utils::render::RenderPass(create_resource_view failed)");
          assert(create_resource_view_result != false);
        }
    }

    reshade::api::descriptor_table_update update[5] = {};
    for (uint32_t i = 0; i < 5; ++i)
    {
        update[i].table = xeGTAO_depth_mip_descriptor_table;
        update[i].binding = i;
        update[i].array_offset = 0;
        update[i].count = 1;
        update[i].type = reshade::api::descriptor_type::texture_unordered_access_view;
        update[i].descriptors = &xeGTAO_depth_mip_uav[i];
    }
    device->update_descriptor_tables(5, update);
  }

  void destroy_resources(reshade::api::device* device) {
    for (uint32_t i = 0; i < 5; ++i)
    {
        if (xeGTAO_depth_mip_uav[i].handle != 0) {
            device->destroy_resource_view(xeGTAO_depth_mip_uav[i]);
            xeGTAO_depth_mip_uav[i] = {};
        }
        if (xeGTAO_depth_mip_srv[i].handle != 0) {
            device->destroy_resource_view(xeGTAO_depth_mip_srv[i]);
            xeGTAO_depth_mip_srv[i] = {};
        }
    }
    if (xeGTAO_depth_mip_texture.handle != 0) {
      device->destroy_resource(xeGTAO_depth_mip_texture);
      xeGTAO_depth_mip_texture = {};
    }
  }
};
#endif

int16_t screen_width = 0;
int16_t screen_height = 0;
bool resource_need_recreate = false;

#ifdef REMOVE_UI
bool isPingInputCandidate = false;
bool isUIDInputCandidate = false;

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
bool hasDenoised = false;
bool hasUpscaled = false;
bool hasAO = false;
bool hasDepth = false;
bool hasNormal = false;
bool hasMV = false;
bool hasReshadeDrawn = false;
bool startGbufferCapture = false;
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
bool OnGTAODepthFilterDispatch(reshade::api::command_list* cmd_list) {
    auto* device = cmd_list->get_device();
    auto* custom_device_data = renodx::utils::data::Get<DeviceData>(device);
    if (custom_device_data == nullptr) return true;

    if (resource_need_recreate) {
        custom_device_data->destroy_resources(device);
        custom_device_data->create_resources(device, screen_width, screen_height);
        resource_need_recreate = false;
    } else if (custom_device_data->xeGTAO_depth_mip_texture.handle == 0 || custom_device_data->xeGTAO_depth_mip_uav[0].handle == 0 || custom_device_data->xeGTAO_depth_mip_srv[0].handle == 0) {
        reshade::log::message(reshade::log::level::info, "Resources handles are 0, creating resources");
        custom_device_data->create_resources(device, screen_width, screen_height);
    }

    hasDepth = true;

    cmd_list->bind_pipeline(reshade::api::pipeline_stage::all_compute, custom_device_data->xeGTAO_depth_filter_pipeline);
    reshade::api::descriptor_table descriptor_table[3] = {custom_device_data->current_descriptor_tables[0], custom_device_data->current_descriptor_tables[1], custom_device_data->xeGTAO_depth_mip_descriptor_table};
    cmd_list->bind_descriptor_tables(reshade::api::shader_stage::all_compute, custom_device_data->xeGTAO_depth_filter_pipeline_layout, 0, 3, descriptor_table);
    cmd_list->barrier(custom_device_data->xeGTAO_depth_mip_texture, reshade::api::resource_usage::unordered_access | reshade::api::resource_usage::shader_resource, reshade::api::resource_usage::unordered_access);
    cmd_list->dispatch((screen_width + 7) / 8, (screen_height + 7) / 8, 1);

    auto* data = renodx::utils::data::Get<renodx::utils::swapchain::DeviceData>(cmd_list->get_device());
    if (data == nullptr) return true;
    const std::shared_lock lock(data->mutex);
    cmd_list->barrier(custom_device_data->xeGTAO_depth_mip_texture, reshade::api::resource_usage::unordered_access, reshade::api::resource_usage::shader_resource);
    for (auto* runtime : data->effect_runtimes) {
      runtime->set_effects_state(true);
      runtime->render_effects(cmd_list, custom_device_data->xeGTAO_depth_mip_uav[0], custom_device_data->xeGTAO_depth_mip_uav[0]);
    }
    cmd_list->barrier(custom_device_data->xeGTAO_depth_mip_texture, reshade::api::resource_usage::shader_resource, reshade::api::resource_usage::unordered_access);
/*
    char buffer[256];
    sprintf(buffer,
        "Pipeline: %llu, Table2: %llu",
        custom_device_data->xeGTAO_depth_filter_pipeline.handle,
        custom_device_data->xeGTAO_depth_mip_descriptor_table.handle);

    reshade::log::message(reshade::log::level::info, buffer);
*/
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
	{0x71C92F19, {
			 .crc32 = 0x71C92F19,
			 .code = __0x71C92F19,
			 .on_draw = &OnGTAODepthFilterDispatch,
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
	/*
	// Don't change it, not a const for xeGTAO
    new renodx::utils::settings::Setting{
        .key = "AOFrame",
        .binding = &shader_injection.ao_temporal_frame,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 64.0f,
        .label = "AO Temporal Frame",
        .section = "Lighting",
        .tooltip = "",
        .labels = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64"},
        .min = 0.f,
        .max = 64.f,
    },
	*/
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
        .default_value = 2.0f,
        .label = "AO Denoiser Blur Beta",
        .section = "Lighting",
        .tooltip = "",
        .min = 0.f,
        .max = 16.f,
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
	auto* data = renodx::utils::data::Get<renodx::mods::swapchain::DeviceData>(device);
	if (!data) return;

	auto bb = device->get_resource_desc(swapchain->get_current_back_buffer());
	if (bb.type == reshade::api::resource_type::unknown) return;
    
    if (bb.texture.width != screen_width || bb.texture.height != screen_height) {
        resource_need_recreate = true;
    }

    screen_width = bb.texture.width;
    screen_height = bb.texture.height;
    shader_injection.ui_aspect_ratio = static_cast<float>(bb.texture.height) / static_cast<float>(bb.texture.width);
    for (auto& target : data->swap_chain_upgrade_targets) {
        target.dimensions = {
            static_cast<int16_t>(bb.texture.width / 2),
            static_cast<int16_t>(bb.texture.height / 2),
            renodx::utils::resource::ResourceUpgradeInfo::ANY
			};
    }
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

    drawParams.index_count = index_count;
    drawParams.instance_count = instance_count;
    drawParams.first_index = first_index;
    drawParams.vertex_offset = vertex_offset;
    drawParams.first_instance = first_instance;

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
#endif
#ifdef RESHADE_AO
  hasAO = false;
  hasDenoised = false;
  hasUpscaled = false;
  hasDepth = false;
  hasNormal = false;
  hasMV = false;
  hasReshadeDrawn = false;
  startGbufferCapture = false;
#endif
	
}


#ifdef RESHADE_AO
void OnInitDevice(reshade::api::device* device) {
	renodx::utils::data::Create<DeviceData>(device);
  auto* data = renodx::utils::data::Get<DeviceData>(device);
  if (data) {
      data->current_descriptor_tables.clear();
      data->setup_xeGTAO_depth_filter(device);
  }
}

void OnDestroyDevice(reshade::api::device* device) {
  auto* data = renodx::utils::data::Get<DeviceData>(device);
  if (data) {
      data->destroy_xeGTAO_depth_filter(device);
      data->destroy_resources(device);
      data->current_descriptor_tables.clear();
  }
  renodx::utils::data::Delete<DeviceData>(device);
}

void OnBindDescriptorTables(
    reshade::api::command_list* cmd_list,
    reshade::api::shader_stage stages,
    reshade::api::pipeline_layout layout,
    uint32_t first,
    uint32_t count,
    const reshade::api::descriptor_table* tables) {

    auto* device = cmd_list->get_device();
    auto* custom_device_data = renodx::utils::data::Get<DeviceData>(device);
    if (custom_device_data == nullptr) return;

    // Resize if needed
    if (custom_device_data->current_descriptor_tables.size() < first + count) {
        custom_device_data->current_descriptor_tables.resize(first + count);
    }
    // Copy the descriptor tables
    for (uint32_t i = 0; i < count; ++i) {
        custom_device_data->current_descriptor_tables[first + i] = tables[i];
    }
}

void OnBeginRenderEffects(reshade::api::effect_runtime *runtime, reshade::api::command_list *cmd_list, reshade::api::resource_view rtv, reshade::api::resource_view rtv_srgb) {
    auto* device = cmd_list->get_device();
	
    auto* renodx_device_data = renodx::utils::data::Get<renodx::utils::swapchain::DeviceData>(device);
    if (renodx_device_data == nullptr) return;
    const std::shared_lock lock(renodx_device_data->mutex);

    auto* custom_device_data = renodx::utils::data::Get<DeviceData>(device);
    if (custom_device_data == nullptr) return;

    if (!hasDepth) {
        for (auto* runtime : renodx_device_data->effect_runtimes) {
            if (runtime == nullptr) continue;

            reshade::api::resource_view empty_view = {0u};
            runtime->update_texture_bindings("DEPTH", empty_view, empty_view);
            reshade::log::message(reshade::log::level::info, "uav handle is 0, binding empty view");
        }
        runtime->set_effects_state(false);
        return;
    }

    for (auto* runtime : renodx_device_data->effect_runtimes) {
        if (runtime == nullptr) continue;

        if (custom_device_data->xeGTAO_depth_mip_srv[0].handle != 0) {
            runtime->update_texture_bindings("DEPTH", custom_device_data->xeGTAO_depth_mip_srv[0], custom_device_data->xeGTAO_depth_mip_srv[0]);
        }
        else
        {
          reshade::api::resource_view empty_view = {0u};
          runtime->update_texture_bindings("DEPTH", empty_view, empty_view);
          reshade::log::message(reshade::log::level::info, "uav handle is 0, binding empty view");
        }
    }

    hasDepth = false;
}
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

	  
      renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
          .old_format = reshade::api::format::r8_typeless,
          .new_format = reshade::api::format::r16g16_typeless,
          .ignore_size = false,
          .use_resource_view_cloning = renodx::mods::swapchain::use_resource_cloning,
          .aspect_ratio = renodx::utils::resource::ResourceUpgradeInfo::BACK_BUFFER,
          .aspect_ratio_tolerance = common_aspect_ratio_tolerance,
          .view_upgrades = {
			   {{reshade::api::resource_usage::shader_resource, reshade::api::format::r8_unorm}, reshade::api::format::r16g16_float},
			   {{reshade::api::resource_usage::unordered_access, reshade::api::format::r8_unorm}, reshade::api::format::r16g16_float},
			   {{reshade::api::resource_usage::render_target, reshade::api::format::r8_unorm}, reshade::api::format::r16g16_float},
			   {{reshade::api::resource_usage::copy_dest, reshade::api::format::r8_unorm}, reshade::api::format::r16g16_float},
			   {{reshade::api::resource_usage::copy_source, reshade::api::format::r8_unorm}, reshade::api::format::r16g16_float},
		  },
      });
	  
	  reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
	  reshade::register_event<reshade::addon_event::present>(OnPresent);
#ifdef REMOVE_UI
	  reshade::register_event<reshade::addon_event::draw_indexed>(OnDrawIndexed);
#endif
	  
#ifdef RESHADE_AO
      reshade::register_event<reshade::addon_event::init_device>(OnInitDevice);
      reshade::register_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
      reshade::register_event<reshade::addon_event::bind_descriptor_tables>(OnBindDescriptorTables);
      reshade::register_event<reshade::addon_event::reshade_begin_effects>(OnBeginRenderEffects);

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
    reshade::unregister_event<reshade::addon_event::reshade_begin_effects>(OnBeginRenderEffects);


#endif      
	
      reshade::unregister_addon(h_module);
      break;
  }

  renodx::utils::settings::Use(fdw_reason, &settings);
#ifdef RESHADE_AO
  renodx::utils::pipeline_layout::Use(fdw_reason);
  renodx::utils::swapchain::Use(fdw_reason);
  renodx::utils::shader::Use(fdw_reason);
  renodx::utils::descriptor::Use(fdw_reason);
#endif
  renodx::mods::swapchain::Use(fdw_reason);
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);

  return TRUE;
}
