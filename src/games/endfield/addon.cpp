/*
 * Copyright (C) 2024 Carlos Lopez
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64

//#define DEBUG_LEVEL_0
//#define DEBUG_LEVEL_1
//#define DEBUG_LEVEL_2

//#define RESHADE_AO
#define REMOVE_UI

#include <embed/shaders.h>

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>

#include "../../mods/shader.hpp"
#include "../../mods/swapchain.hpp"
#include "../../templates/settings.hpp"
#include "../../utils/date.hpp"
#include "../../utils/random.hpp"
#include "../../utils/settings.hpp"
#include "./shared.h"

namespace {

#ifdef RESHADE_AO
struct __declspec(uuid("595827c4-19b2-4300-af4d-c6802d6c7636")) DeviceData {
	reshade::api::resource_view srv_depth = { 0 };
	reshade::api::resource_view srv_normal_worldspace = { 0 };
	reshade::api::resource_view srv_mv = { 0 };
  reshade::api::resource_view uav_ao = { 0 };
  reshade::api::resource_usage uav_original_usages = (reshade::api::resource_usage::undefined);
  reshade::api::resource uav_ao_texture = { 0 };
  uint64_t uav_resource_handle = 0;
	
  reshade::api::resource_view prev_srv_depth = { 0 };
  reshade::api::resource_view prev_srv_normal_worldspace = { 0 };
  reshade::api::resource_view prev_srv_mv = { 0 };
	reshade::api::resource_view prev_uav_ao = { 0 };
#ifdef TRACE_DESC
	std::map<std::pair<uint32_t, uint32_t>, reshade::api::resource_view> compute_uav_binds;
	std::map<std::pair<uint32_t, uint32_t>, reshade::api::buffer_range> constants;
#endif
};
#endif

int16_t screen_width = 0;
int16_t screen_height = 0;

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
    /*
    if (shader_injection.ui_aspect_ratio != ui_aspect)
    {
        shader_injection.ui_aspect_ratio = ui_aspect;
    }
    */
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
bool OnNormalDepthBlit(reshade::api::command_list* cmd_list) {
    auto* cmd_list_data = renodx::utils::data::Get<renodx::utils::swapchain::CommandListData>(cmd_list);
    if (cmd_list_data == nullptr) return true;
    if (cmd_list_data->current_render_targets.empty()) return true;

    auto rtv0 = cmd_list_data->current_render_targets[0];
    if (rtv0.handle == 0) return true;

    auto* device = cmd_list->get_device();
	/*
    auto* renodx_device_data = renodx::utils::data::Get<renodx::utils::swapchain::DeviceData>(device);
    if (renodx_device_data == nullptr) return true;
    const std::shared_lock lock(renodx_device_data->mutex);
  */
    auto* custom_device_data = renodx::utils::data::Get<DeviceData>(device);
    if (custom_device_data == nullptr) return true;

	
    reshade::api::resource_view_desc current_rtv_desc = device->get_resource_view_desc(rtv0);
	
	if (current_rtv_desc.format == reshade::api::format::r32_float) {
		custom_device_data->srv_depth = rtv0;
    hasDepth = true;
	}
	else if (current_rtv_desc.format == reshade::api::format::r10g10b10a2_unorm ) {
		custom_device_data->srv_normal_worldspace = rtv0;
    hasNormal = true;
    startGbufferCapture = true;
	}

    return true;
}

bool OnMotionBlit(reshade::api::command_list* cmd_list) {
    auto* cmd_list_data = renodx::utils::data::Get<renodx::utils::swapchain::CommandListData>(cmd_list);
    if (cmd_list_data == nullptr) return true;
    if (cmd_list_data->current_render_targets.empty()) return true;

    auto rtv0 = cmd_list_data->current_render_targets[2];
    if (rtv0.handle == 0) return true;

    auto* device = cmd_list->get_device();
	/*
    auto* renodx_device_data = renodx::utils::data::Get<renodx::utils::swapchain::DeviceData>(device);
    if (renodx_device_data == nullptr) return true;
    const std::shared_lock lock(renodx_device_data->mutex);

    reshade::api::resource_view_desc current_rtv_desc = device->get_resource_view_desc(rtv0);
  */


    auto* custom_device_data = renodx::utils::data::Get<DeviceData>(device);
    if (custom_device_data == nullptr) return true;

	  custom_device_data->srv_mv = rtv0;
    hasMV = true;

    return true;
}

bool OnDenoiserFinish(reshade::api::command_list* cmd_list) {
    hasDenoised = true;
    hasAO = true;
    return true;
}

bool OnUpsampleFinish(reshade::api::command_list* cmd_list) {
    auto* cmd_list_data = renodx::utils::data::Get<renodx::utils::swapchain::CommandListData>(cmd_list);
    if (cmd_list_data == nullptr) return true;

    auto* device = cmd_list->get_device();

    auto* custom_device_data = renodx::utils::data::Get<DeviceData>(device);
    if (custom_device_data == nullptr) return true;
    if (custom_device_data->uav_ao.handle == 0) return true;

    auto* data = renodx::utils::data::Get<renodx::utils::swapchain::DeviceData>(cmd_list->get_device());
    if (data == nullptr) return true;
    const std::shared_lock lock(data->mutex);
    cmd_list->barrier(custom_device_data->uav_ao_texture, custom_device_data->uav_original_usages, reshade::api::resource_usage::render_target);
    hasReshadeDrawn = true;
    for (auto* runtime : data->effect_runtimes) {
      runtime->set_effects_state(true);
      runtime->render_effects(cmd_list, custom_device_data->uav_ao, custom_device_data->uav_ao);
    }
    cmd_list->barrier(custom_device_data->uav_ao_texture, reshade::api::resource_usage::render_target, custom_device_data->uav_original_usages);
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
	{0x47FB91F9, {
			 .crc32 = 0x47FB91F9,
			 .on_draw = &OnNormalDepthBlit,
		 },
	},
  /*
	{0xC14B0925, {
			 .crc32 = 0xC14B0925,
			 .on_draw = &OnMotionBlit,
		 },
	},
  */
	{0x3F1D52C5, {
			 .crc32 = 0x3F1D52C5,
       .code = __0x3F1D52C5,
			 .on_drawn = &OnDenoiserFinish,
		 },
	},
	{0x21E2F7BD, {
			 .crc32 = 0x21E2F7BD,
       .code = __0x21E2F7BD,
			 .on_drawn = &OnUpsampleFinish,
		 },
	},
#endif
/*
	{0x21E2F7BD, {
			 .crc32 = 0x21E2F7BD,
			 .code = __0x21E2F7BD,
			 .on_dispatch = &OnAOUpsampling,
		 },
	},
*/
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
        .max = 2.f,
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
        .label = "SSR Max Step Count",
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
    
    shader_injection.ui_aspect_ratio = static_cast<float>(bb.texture.height) / static_cast<float>(bb.texture.width);
    /*
    reshade::log::message(
        reshade::log::level::debug,
        std::format("Swapchain - width:{} height:{} ratio:{}", static_cast<float>(bb.texture.width), static_cast<float>(bb.texture.height), ui_aspect).c_str());*/
  
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
}

void OnDestroyDevice(reshade::api::device* device) {
    renodx::utils::data::Delete<DeviceData>(device);
}

void OnBeginRenderEffects(reshade::api::effect_runtime *runtime, reshade::api::command_list *cmd_list, reshade::api::resource_view rtv, reshade::api::resource_view rtv_srgb) {
    auto* device = cmd_list->get_device();
	
    auto* renodx_device_data = renodx::utils::data::Get<renodx::utils::swapchain::DeviceData>(device);
    if (renodx_device_data == nullptr) return;
    const std::shared_lock lock(renodx_device_data->mutex);

    auto* custom_device_data = renodx::utils::data::Get<DeviceData>(device);
    if (custom_device_data == nullptr) return;

    // somehow this works now
    // resets all the views if not present this frame
    if (!hasAO)
    {
        custom_device_data->uav_ao = { 0 };
        custom_device_data->uav_original_usages = (reshade::api::resource_usage::undefined);
        custom_device_data->uav_resource_handle = 0;
    }

    if (!hasDepth)
    {
        custom_device_data->srv_depth = { 0 };
    }

    if (!hasNormal)
    {
        custom_device_data->srv_normal_worldspace = { 0 };
    }

    if (!hasMV)
    {
        custom_device_data->srv_mv = { 0 };
    }

    if (!hasReshadeDrawn) {
      runtime->set_effects_state(false);
    }

    for (auto* runtime : renodx_device_data->effect_runtimes) {
        if (runtime == nullptr) continue;

        if (custom_device_data->srv_depth.handle != 0) {
          if (custom_device_data->srv_depth.handle != custom_device_data->prev_srv_depth.handle) {
              runtime->update_texture_bindings("DEPTH", custom_device_data->srv_depth, custom_device_data->srv_depth);
              custom_device_data->prev_srv_depth = custom_device_data->srv_depth;
          }
        }
        else
        {
          reshade::api::resource_view empty_view = {0u};
          runtime->update_texture_bindings("DEPTH", empty_view, empty_view);
        }

        if (custom_device_data->srv_normal_worldspace.handle != 0) {
          if (custom_device_data->srv_normal_worldspace.handle != custom_device_data->prev_srv_normal_worldspace.handle) {
              runtime->update_texture_bindings("NORMAL_WS", custom_device_data->srv_normal_worldspace, custom_device_data->srv_normal_worldspace);
              custom_device_data->prev_srv_normal_worldspace = custom_device_data->srv_normal_worldspace;
          }
        }
        else
        {
          reshade::api::resource_view empty_view = {0u};
          runtime->update_texture_bindings("NORMAL_WS", empty_view, empty_view);
        }

        if (custom_device_data->srv_mv.handle != 0) {
          if (custom_device_data->srv_mv.handle != custom_device_data->prev_srv_mv.handle) {
              runtime->update_texture_bindings("MOTION_VECTOR", custom_device_data->srv_mv, custom_device_data->srv_mv);
              custom_device_data->prev_srv_mv = custom_device_data->srv_mv;
          }
        }
        else
        {
          reshade::api::resource_view empty_view = {0u};
          runtime->update_texture_bindings("MOTION_VECTOR", empty_view, empty_view);
        }

        if (custom_device_data->uav_ao.handle != 0) {
          if (custom_device_data->uav_ao.handle != custom_device_data->prev_uav_ao.handle) {
            runtime->update_texture_bindings("FINAL_AO", custom_device_data->uav_ao, custom_device_data->uav_ao);
            custom_device_data->prev_uav_ao = custom_device_data->uav_ao;
          }
        }
        else
        {
          reshade::api::resource_view empty_view = {0u};
          runtime->update_texture_bindings("FINAL_AO", empty_view, empty_view);
        }
		
    }
    hasAO = false;
    hasDepth = false;
    hasNormal = false;
    hasMV = false;
}

std::vector<reshade::api::resource_view> GetResourceViewsFromResource(const reshade::api::resource& target_resource, const reshade::api::device* device) {
    std::vector<reshade::api::resource_view> result_views;
    auto* resource_data = renodx::utils::data::Get<renodx::utils::resource::DeviceData>(device);
    if (resource_data == nullptr) return result_views;
    
    if (target_resource.handle == 0u) {
        return result_views;
    }
    
    renodx::utils::resource::ResourceInfo* target_resource_info = renodx::utils::resource::GetResourceInfo(target_resource, false);
    if (target_resource_info == nullptr || target_resource_info->destroyed) {
        //log::w("utils::resource::GetResourceViewsFromResource(Invalid or destroyed resource: ", log::AsPtr(target_resource.handle), ")");
        return result_views;
    }
    
    resource_data->store->resource_view_infos.for_each([&](const std::pair<const uint64_t, renodx::utils::resource::ResourceViewInfo>& pair) {
        const renodx::utils::resource::ResourceViewInfo& view_info = pair.second;
        
        if (!view_info.destroyed && 
            view_info.original_resource.handle == target_resource.handle && 
            view_info.resource_info == target_resource_info) {
            result_views.push_back(view_info.view);
        }
    });
    
    return result_views;
}

void OnBeginRenderPass(
    reshade::api::command_list* cmd_list,
    uint32_t count, const reshade::api::render_pass_render_target_desc* rts,
    const reshade::api::render_pass_depth_stencil_desc* ds) {
      if (!startGbufferCapture) return;
      startGbufferCapture = false;
      auto* device = cmd_list->get_device();
      auto* custom_device_data = renodx::utils::data::Get<DeviceData>(device);
      if (custom_device_data == nullptr) return;

      for (uint32_t i = 0; i < count; i++) {
        // 0 - emissive
        // 1 - mv
        // 2 - rough ao translucency
        // 3 - normal worldspace
        // 4 - albedo
          if (i == 1)
          {
            custom_device_data->srv_mv = rts[i].view;
            hasMV = true;
          }
      }

}

void OnBarrier(
    reshade::api::command_list* cmd_list,
    uint32_t count,
    const reshade::api::resource* resources,
    const reshade::api::resource_usage* old_states,
    const reshade::api::resource_usage* new_states) {

    auto* device = cmd_list->get_device();
    auto* custom_device_data = renodx::utils::data::Get<DeviceData>(device);
    if (custom_device_data == nullptr)
    {
        custom_device_data->uav_ao = { 0 };
        custom_device_data->uav_original_usages = (reshade::api::resource_usage::undefined);
        custom_device_data->uav_resource_handle = 0;
        return;
    }

    if (hasDenoised) {
        if (custom_device_data == nullptr) return;
        if (count > 2) return;

        //auto all_views = GetResourceViewsFromResource(resources[1], device);
        //if (!all_views.empty()) {
            //custom_device_data->uav_ao = all_views[0];
//#define DEBUG_AO_RESOURCE

        uint32_t full_res_index = 0;
        auto current_uav_desc = device->get_resource_desc(resources[0]);
        uint32_t index_0_width = static_cast<unsigned int>(current_uav_desc.texture.width);
        current_uav_desc = device->get_resource_desc(resources[1]);
        if (index_0_width > static_cast<unsigned int>(current_uav_desc.texture.width)) {
            full_res_index = 0;
        }
        else {
            full_res_index = 1;
        }

#ifdef DEBUG_AO_RESOURCE
        reshade::log::message(
            reshade::log::level::debug,
            std::format("Found GTAO UAV at index {} - widht:{} height:{}", full_res_index, static_cast<unsigned int>(current_uav_desc.texture.width), static_cast<unsigned int>(current_uav_desc.texture.height)).c_str());
#endif 
        custom_device_data->uav_original_usages = new_states[full_res_index];
        custom_device_data->uav_ao_texture = resources[full_res_index];
        if (resources[full_res_index].handle != custom_device_data->uav_resource_handle) {
            custom_device_data->uav_resource_handle = resources[full_res_index].handle;
            auto all_views = GetResourceViewsFromResource(resources[full_res_index], device);
            if (!all_views.empty()) {
                custom_device_data->uav_ao = all_views[0];
            }
        }

        //return all_views[0];

    hasDenoised = false;
    return;
  }

    //device->create_resource_view()
    /*
    for (uint32_t i = 0; i < count; i++) {
      
      std::stringstream s;
      s << "on_barrier(" << PRINT_PTR(resources[i].handle);
      s << ", " << std::hex << static_cast<uint32_t>(old_states[i]) << std::dec << " (" << old_states[i] << ")";
      s << " => " << std::hex << static_cast<uint32_t>(new_states[i]) << std::dec << " (" << new_states[i] << ")";
      s << ") [" << i << "]";
      reshade::log::message(reshade::log::level::info, s.str().c_str());
      
    }
    */


  // need better way to reset them but idk


  return;

}
#ifdef TRACE_DESC
void OnInitCommandList(reshade::api::command_list* cmd_list) {
  renodx::utils::data::Create<DeviceData>(cmd_list);
}

void OnDestroyCommandList(reshade::api::command_list* cmd_list) {
  renodx::utils::data::Delete<DeviceData>(cmd_list);
}

void OnResetCommandList(reshade::api::command_list* cmd_list) {
  auto* data = renodx::utils::data::Get<DeviceData>(cmd_list);
  if (data == nullptr) return;
  renodx::utils::data::Delete<DeviceData>(cmd_list);
  renodx::utils::data::Create<DeviceData>(cmd_list);
}

bool OnDispatchTest(
    reshade::api::command_list* cmd_list,
    uint32_t group_count_x,
    uint32_t group_count_y,
    uint32_t group_count_z) {

if (hasDenoised) {
  auto* shader_state = renodx::utils::shader::GetCurrentState(cmd_list);

  auto* compute_state = renodx::utils::shader::GetCurrentComputeState(shader_state);

  auto compute_shader_hash = renodx::utils::shader::GetCurrentComputeShaderHash(compute_state);
  if (compute_shader_hash == 0u) return false;
  if (compute_shader_hash != 0x21E2F7BD) return false;
  
  auto* cmd_list_data = renodx::utils::data::Get<DeviceData>(cmd_list);

  auto compute_uav_binds = cmd_list_data->compute_uav_binds;

  auto* device = cmd_list->get_device();

  if (shader_state->last_pipeline != 0u) {
    auto* pipeline_shader_details = renodx::utils::shader::GetPipelineShaderDetails(shader_state->last_pipeline);
	/*
	reshade::log::message(
					  reshade::log::level::debug,
					  std::format("Found pipeline_shader_details: 0x{:08x}", compute_shader_hash).c_str());*/
					  
    if (pipeline_shader_details != nullptr) {
      auto* layout_data = renodx::utils::pipeline_layout::GetPipelineLayoutData(pipeline_shader_details->layout);
      if (layout_data != nullptr) {
        const auto& info = *layout_data;
        auto param_count = info.params.size();
        auto* descriptor_data = renodx::utils::data::Get<renodx::utils::descriptor::DeviceData>(device);
        if (descriptor_data == nullptr) return false;
		/*
		reshade::log::message(
					  reshade::log::level::debug,
					  std::format("Found descriptor_data: 0x{:08x} {}", compute_shader_hash, param_count).c_str());*/

        for (auto param_index = 0; param_index < param_count; ++param_index) {
          const auto& param = info.params.at(param_index);
          const auto& table = info.tables[param_index];
		  /*
		  reshade::log::message(
					  reshade::log::level::debug,
					  std::format("Found descriptor_table_type: 0x{:08x} {}", compute_shader_hash, static_cast<unsigned int>(param.type)).c_str());*/

          uint32_t descriptor_table_count;
          const reshade::api::descriptor_range* descriptor_table_ranges;
          switch (param.type) {
            case reshade::api::pipeline_layout_param_type::descriptor_table:
              if (table.handle == 0u) 
			  {
				  reshade::log::message(
							  reshade::log::level::debug,
							  std::format("Can't get table handle: 0x{:08x}", compute_shader_hash).c_str());
				  continue;
			  }
              descriptor_table_count = param.descriptor_table.count;
              descriptor_table_ranges = param.descriptor_table.ranges;
              break;
            case reshade::api::pipeline_layout_param_type::descriptor_table_with_static_samplers:
              if (table.handle == 0u) continue;
              descriptor_table_count = param.descriptor_table_with_static_samplers.count;
              descriptor_table_ranges = param.descriptor_table_with_static_samplers.ranges;
              break;

            case reshade::api::pipeline_layout_param_type::push_constants:
            case reshade::api::pipeline_layout_param_type::push_descriptors:
            case reshade::api::pipeline_layout_param_type::push_descriptors_with_ranges:
            case reshade::api::pipeline_layout_param_type::push_descriptors_with_static_samplers:
              continue;
          }
		  
		  reshade::log::message(
					  reshade::log::level::debug,
					  std::format("Found descriptor_table: 0x{:08x} {}", compute_shader_hash, descriptor_table_count).c_str());

          for (uint32_t j = 0; j < descriptor_table_count; ++j) {
            const auto& range = descriptor_table_ranges[j];

            // Skip unbounded ranges
            if (range.count == UINT32_MAX) continue;

            switch (range.type) {
              case reshade::api::descriptor_type::shader_resource_view:
              case reshade::api::descriptor_type::sampler_with_resource_view:
              case reshade::api::descriptor_type::buffer_shader_resource_view:
              case reshade::api::descriptor_type::unordered_access_view:
                break;
              default:
                continue;
            }

            if (!renodx::utils::bitwise::HasFlag(range.visibility, reshade::api::shader_stage::compute)) {
              continue;
            }
            // if (!renodx::utils::bitwise::HasFlag(range.visibility, reshade::api::shader_stage::pixel)) {
            //   continue;
            // }

            uint32_t base_offset = 0;
            reshade::api::descriptor_heap heap = {0};
            device->get_descriptor_heap_offset(table, range.binding, 0, &heap, &base_offset);
            //const std::shared_lock descriptor_lock(descriptor_data->mutex);

		  reshade::log::message(
					  reshade::log::level::debug,
					  std::format("Found descriptor_heap: 0x{:08x} {}", compute_shader_hash, static_cast<unsigned int>(base_offset)).c_str());

            for (uint32_t k = 0; k < range.count; ++k) {
              auto heap_pair = descriptor_data->heaps.find(heap.handle);
              if (heap_pair == descriptor_data->heaps.end()) {
                // Unknown heap?

              reshade::log::message(
                    reshade::log::level::debug,
                    std::format("Unknown heap: 0x{:08x}", compute_shader_hash).c_str());
                continue;
              }
              const auto& heap_data = heap_pair->second;
              auto offset = base_offset + k;
              if (offset >= heap_data.size()) {
                // Invalid location (may be oversized bind)
              reshade::log::message(
                    reshade::log::level::debug,
                    std::format("Invalid heap: 0x{:08x}", compute_shader_hash).c_str());
                continue;
              }
              auto known_pair = descriptor_data->resource_view_heap_locations.find(heap.handle);
              if (known_pair == descriptor_data->resource_view_heap_locations.end()) continue;

              reshade::log::message(
                    reshade::log::level::debug,
                    std::format("Found descriptor data: 0x{:08x}", compute_shader_hash).c_str());

              auto& known = known_pair->second;
              if (!known.contains(offset)) {
                // Unknown Resource View
                continue;
              }

              const auto& [descriptor_type, descriptor_data] = heap_data[offset];
              reshade::api::resource_view resource_view = {0};

              reshade::log::message(
                    reshade::log::level::debug,
                    std::format("Found descriptor_table_type: 0x{:08x} {}", compute_shader_hash, static_cast<unsigned int>(descriptor_type)).c_str());

              bool is_uav = false;
              switch (descriptor_type) {
                case reshade::api::descriptor_type::texture_unordered_access_view:
                  is_uav = true;
                  resource_view = std::get<reshade::api::resource_view>(descriptor_data);

                  reshade::log::message(
                              reshade::log::level::debug,
                              std::format("Found uav: 0x{:08x}", compute_shader_hash).c_str());
                  break;
                default:
                  break;
              }

              auto slot = std::pair<uint32_t, uint32_t>(range.dx_register_index + k, range.dx_register_space);

              if (is_uav || range.type == reshade::api::descriptor_type::unordered_access_view) {
                if (resource_view.handle == 0u) {
                  compute_uav_binds.erase(slot);
                } else {
                  auto* resource_view_info = renodx::utils::resource::GetResourceViewInfo(resource_view);
                  if (resource_view_info->resource_info == nullptr && renodx::utils::resource::IsResourceViewEmpty(device, resource_view)) {
                    compute_uav_binds.erase(slot);
                  } else {
                    compute_uav_binds[slot] = resource_view;
                  }
                }
              } else {
                // if (resource_view.handle == 0u) {
                //   draw_details.srv_binds.erase(slot);
                // } else {
                //   auto detail_item = GetResourceViewDetails(resource_view, device);
                //   if (detail_item.resource.handle == 0u && renodx::utils::resource::IsResourceViewEmpty(device, resource_view)) {
                //     draw_details.srv_binds.erase(slot);
                //   } else {
                //     draw_details.srv_binds[slot] = detail_item;
                //   }
                // }
              }
            }
          }
        }
      }
    }
  }
  hasDenoised = false;
}

  return false;
}

void OnBindDescriptorTables(
    reshade::api::command_list* cmd_list,
    reshade::api::shader_stage stages,
    reshade::api::pipeline_layout layout,
    uint32_t first,
    uint32_t count,
    const reshade::api::descriptor_table* tables) {

      if (hasDenoised) {
        auto* device = cmd_list->get_device();
        auto* layout_data = renodx::utils::pipeline_layout::GetPipelineLayoutData(layout);

        assert(layout_data != nullptr);

        auto& info = *layout_data;
        for (uint32_t i = 0; i < count; ++i) {
          const auto layout_index = first + i;

          assert(layout_index < info.params.size());
          const auto& param = info.params.at(layout_index);
          assert(param.type == reshade::api::pipeline_layout_param_type::descriptor_table
                || param.type == reshade::api::pipeline_layout_param_type::descriptor_table_with_static_samplers);

          info.tables[layout_index] = tables[i];
        }
      }
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
	  reshade::register_event<reshade::addon_event::reshade_begin_effects>(OnBeginRenderEffects);
    reshade::register_event<reshade::addon_event::begin_render_pass>(OnBeginRenderPass);
    reshade::register_event<reshade::addon_event::barrier>(OnBarrier);

#ifdef TRACE_DESC
	    reshade::register_event<reshade::addon_event::dispatch>(OnDispatchTest);
      reshade::register_event<reshade::addon_event::bind_descriptor_tables>(OnBindDescriptorTables);
      reshade::register_event<reshade::addon_event::init_command_list>(OnInitCommandList);
      reshade::register_event<reshade::addon_event::reset_command_list>(OnResetCommandList);
      reshade::register_event<reshade::addon_event::destroy_command_list>(OnDestroyCommandList);

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
	  reshade::unregister_event<reshade::addon_event::reshade_begin_effects>(OnBeginRenderEffects);
    reshade::unregister_event<reshade::addon_event::begin_render_pass>(OnBeginRenderPass);
    reshade::unregister_event<reshade::addon_event::barrier>(OnBarrier);

#ifdef TRACE_DESC
      reshade::unregister_event<reshade::addon_event::dispatch>(OnDispatchTest);
    reshade::unregister_event<reshade::addon_event::bind_descriptor_tables>(OnBindDescriptorTables);
      reshade::unregister_event<reshade::addon_event::init_command_list>(OnInitCommandList);
      reshade::unregister_event<reshade::addon_event::reset_command_list>(OnResetCommandList);
      reshade::unregister_event<reshade::addon_event::destroy_command_list>(OnDestroyCommandList);
      reshade::unregister_event<reshade::addon_event::bind_descriptor_tables>(OnBindDescriptorTables);
#endif
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
