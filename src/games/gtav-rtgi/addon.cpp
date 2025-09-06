/*
 * Copyright (C) 2024 Carlos Lopez
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64

#define DEBUG_LEVEL_0
//#define DEBUG_LEVEL_1
//#define DEBUG_LEVEL_2

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>

#include <embed/0x641D6E22.h>
#include <embed/0xB1E7F9B6.h>
#include <embed/0x1BE1F747.h>
#include <embed/0x8A4973A1.h>
#include <embed/0x73DAE4E4.h>
#include <embed/0x75D65BF5.h>
#include <embed/0x866EC669.h>
#include <embed/0x58299E0B.h>
#include <embed/0xD9BDD5FD.h>
#include <embed/0xDE210720.h>
#include <embed/0xEAECB05E.h>
#include <embed/shaders.h>

//#include "../../utils/data.hpp"
//#include "../../utils/descriptor.hpp"
//#include "../../utils/pipeline_layout.hpp"
#include "../../mods/shader.hpp"
#include "../../mods/swapchain.hpp"
//#include "../../utils/swapchain.hpp"
#include "../../utils/platform.hpp"
//#include "../../utils/random.hpp"
#include "../../utils/settings.hpp"
#include "./shared.h"

namespace {
	
reshade::api::command_queue *g_command_queue = nullptr;
bool g_use_shaders = false;
float use_character_highlight = 1.0f;
	
bool OnTestDrawn(reshade::api::command_list* cmd_list) {

  if (g_command_queue != nullptr)
	g_command_queue->wait_idle();

  return true;
}

renodx::mods::shader::CustomShaders custom_shaders = {
	
    {0xB1E7F9B6, {
                     .crc32 = 0xB1E7F9B6,
					 .code = __0xB1E7F9B6,
                     .on_draw = &OnTestDrawn,
                 }},	//PS_ApplyTemporalAccumulationLitColor_RTIndirectDiffuse
	CustomShaderEntry(0x1BE1F747),	//BilaterialSeparableX_RTGI
	CustomShaderEntry(0x8A4973A1),	//PS_directional_scatter
	CustomShaderEntry(0x73DAE4E4),	//PS_directional_underwater
	CustomShaderEntry(0x75D65BF5),	//BilaterialSeparableY
	CustomShaderEntry(0x866EC669),	//PS_directional_standard
	CustomShaderEntry(0x58299E0B),	//PS_directional_ambient
	CustomShaderEntry(0xD9BDD5FD),	//BilaterialSeparableY_Small
	CustomShaderEntry(0xDE210720),	//CS_RaytraceIndirectDiffuseSecondBounce32
	CustomShaderEntry(0xEAECB05E),	//BilaterialSeparableX_Small
	{0x641D6E22, {
                     .crc32 = 0x641D6E22,
					 .code = __0x641D6E22,
                     .on_draw = [](auto* cmd_list) {
							return use_character_highlight == 1.f;
					 },
                 },
	},
};

ShaderInjectData shader_injection;

float current_settings_mode = 0;

const std::string build_date = __DATE__;
const std::string build_time = __TIME__;


renodx::utils::settings::Settings settings = {
	new renodx::utils::settings::Setting{
		.key = "UseSkyBounce",
        .binding = &shader_injection.gUseSkyBounce,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.0f,
        .label = "Sky Bounce Light",
        .section = "RTGI",
        .tooltip = "Expensive - trace sky bounce lighting.",
        .labels = {"Off", "On"},
    },
	new renodx::utils::settings::Setting{
        .key = "MaxRayT",
        .binding = &shader_injection.gRayDistSkyBounce,
        .default_value = 256.f,
        .label = "Sky Bounce Ray Max Length",
        .section = "RTGI",
        .tooltip = "Adjust sky bounce ray's max length.",
        .min = 128.f,
        .max = 256.f,
    },
	new renodx::utils::settings::Setting{
        .key = "RoughnessThreshold",
        .binding = &shader_injection.gRoughnessThreshold,
        .default_value = 0.29f,
        .label = "Roughness Threshold",
        .section = "RTGI",
        .tooltip = "Roughness below threshold wont be traced.",
        .min = 0.f,
        .max = 1.f,
		.format = "%.2f",
    },
	new renodx::utils::settings::Setting{
        .key = "SpecIntensityThreshold",
        .binding = &shader_injection.gSpecIntensityThreshold,
        .default_value = 0.30f,
        .label = "SpecIntensity Threshold",
        .section = "RTGI",
        .tooltip = "SpecIntensity below threshold wont be traced.",
        .min = 0.f,
        .max = 1.f,
		.format = "%.2f",
    },
	new renodx::utils::settings::Setting{
		.key = "UseAtomsphere",
        .binding = &shader_injection.gUseAtomsphere,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.0f,
        .label = "Use Atomsphere Color as Sky Light",
        .section = "RTGI",
        .tooltip = "Blend sky ambient color with atmosphere color.",
        .labels = {"Off", "On"},
    },
	new renodx::utils::settings::Setting{
		.key = "DebugFull",
        .binding = &shader_injection.gDebugFull,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 0.0f,
        .label = "Full Resolution RTGI Mode",
        .section = "RTGI",
        .tooltip = "For debug purpose. Calculate every pixel each frame and disable temporal upscaling.",
        .labels = {"Off", "On"},
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
		.label = "Fix Denoiser",
        .section = "Lighting",
		.tooltip = "Fix denoiser when everything looks noisy.",
        .on_change = []() {
          g_use_shaders = true;
        },
    },
	new renodx::utils::settings::Setting{
		.key = "JitterReflection",
        .binding = &shader_injection.gJitterReflection,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 0.0f,
        .label = "Jitter Cubemap Reflections",
        .section = "Lighting",
        .tooltip = "Jitter reflection to make reflection sharper but will create unstable reflections.",
        .labels = {"Off", "On"},
    },
	new renodx::utils::settings::Setting{
        .key = "ArtificialAmbientScale",
        .binding = &shader_injection.gArtificialAmbientScale,
        .default_value = 0.0f,
        .label = "Artificial Ambient Scale",
        .section = "Lighting",
        .tooltip = "Scale fake artificial light ambient.",
        .min = 0.f,
        .max = 1.f,
		.format = "%.2f",
    },
    new renodx::utils::settings::Setting{
		.key = "CharacterHighlight",
        .binding = &use_character_highlight,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.0f,
        .label = "Fake Character Highlight",
        .section = "Lighting",
        .tooltip = "Toggles fake highlight on characters. Will affect cutscenes.",
        .labels = {"Off", "On"},
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
    },
};

void OnInitCommandQueue(reshade::api::command_queue *queue)
{
    g_command_queue = queue;
}

void OnDestroyCommandQueue(reshade::api::command_queue *queue)
{
    if (g_command_queue == queue)
        g_command_queue = nullptr;
}

void OnExecuteCommandList(reshade::api::command_queue *queue, reshade::api::command_list* cmd_list)
{
	g_command_queue = queue;
}

void OnPresent(
    reshade::api::command_queue* queue,
    reshade::api::swapchain* swapchain,
    const reshade::api::rect* source_rect,
    const reshade::api::rect* dest_rect,
    uint32_t dirty_rect_count,
    const reshade::api::rect* dirty_rects) {
	
	g_command_queue = queue;
	
   if (g_use_shaders) {
     auto* device = swapchain->get_device();
     if (device == nullptr) {
       reshade::log::message(reshade::log::level::error, "Device is null in OnPresent");
       return;
     }

     for (const auto& [hash, shader] : custom_shaders) {
		   
       renodx::utils::shader::RemoveRuntimeReplacements(device, {hash});
       renodx::utils::shader::AddRuntimeReplacement(device, hash, shader.code);
		 
     }
	 g_use_shaders = false;
   }
}

bool initialized = false;

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "RenoDX for GTA:V Enhanced";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID lpv_reserved) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;
	  
      renodx::mods::shader::on_init_pipeline_layout = [](reshade::api::device* device, auto, auto) {
        return device->get_api() == reshade::api::device_api::d3d12;  // So overlays dont kill the game
      };
	  
      if (!initialized) {

			renodx::utils::settings::use_presets = false;
			renodx::mods::shader::force_pipeline_cloning = true;
			renodx::mods::shader::expected_constant_buffer_space = 50;
			renodx::mods::shader::expected_constant_buffer_index = 13;
			renodx::mods::shader::allow_multiple_push_constants = true;
			
			renodx::utils::shader::use_shader_cache = true;
			renodx::utils::shader::use_replace_async = true;

			renodx::mods::swapchain::use_resource_cloning = true;
			renodx::mods::swapchain::ignored_window_class_names = {"RGSCD3D12_TEMPWINDOW"};

			renodx::mods::swapchain::force_borderless = true;
			renodx::mods::swapchain::prevent_full_screen = true;
			
			renodx::mods::swapchain::target_format = reshade::api::format::b8g8r8a8_unorm;
			renodx::mods::swapchain::target_color_space = reshade::api::color_space::srgb_nonlinear;
			renodx::mods::swapchain::set_color_space = false;

			for (auto index : {0, 1, 2, 3, 4}) {
				renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
					.old_format = reshade::api::format::r16_float,
					.new_format = reshade::api::format::r16g16_float,
					.index = index,
					.use_resource_view_cloning = true,
					.aspect_ratio = renodx::mods::swapchain::SwapChainUpgradeTarget::BACK_BUFFER,
					.view_upgrades = {
						 {{reshade::api::resource_usage::shader_resource,
						   reshade::api::format::r16_float},
						  reshade::api::format::r16g16_float},
						 {{reshade::api::resource_usage::render_target,
						   reshade::api::format::r16_float},
						  reshade::api::format::r16g16_float},
					}
				});
			}
	  }
	  initialized = true;
	  
	  reshade::register_event<reshade::addon_event::init_command_queue>(OnInitCommandQueue);
	  reshade::register_event<reshade::addon_event::destroy_command_queue>(OnDestroyCommandQueue);
	  reshade::register_event<reshade::addon_event::execute_command_list>(OnExecuteCommandList);
	  reshade::register_event<reshade::addon_event::present>(OnPresent);

      break;
    case DLL_PROCESS_DETACH:
      reshade::unregister_addon(h_module);
	  reshade::unregister_event<reshade::addon_event::init_command_queue>(OnInitCommandQueue);
	  reshade::unregister_event<reshade::addon_event::destroy_command_queue>(OnDestroyCommandQueue);
	  reshade::unregister_event<reshade::addon_event::execute_command_list>(OnExecuteCommandList);
	  reshade::unregister_event<reshade::addon_event::present>(OnPresent);
      break;
  }

  renodx::utils::settings::Use(fdw_reason, &settings);
  //renodx::utils::swapchain::Use(fdw_reason);
  renodx::mods::swapchain::Use(fdw_reason);
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);

  return TRUE;
}
