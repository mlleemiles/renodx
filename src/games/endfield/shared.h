#ifndef SRC_BLOODBORNE_SHARED_H_
#define SRC_BLOODBORNE_SHARED_H_

/*
  Shaders use different push constants (depends on pipeline not shaders actually. So if a vertex shader is using
  push constants but not frag/pixel shader, then that vertex shader push constant has to be accounted for
  since they share the same pipeline)

  Anyway, here we define different offsets based on shader used
*/
#ifdef USE_SETTINGS_PUSHCONSTANTS
#define PUSH_CONSTANTS_OFFSET 16
#endif

#ifdef USE_AUX_PUSHCONSTANTS
#define PUSH_CONSTANTS_OFFSET 128
#endif

// Fallback
#ifndef PUSH_CONSTANTS_OFFSET
#define PUSH_CONSTANTS_OFFSET 0
#endif

// Must be 32bit aligned
// Should be 4x32
struct ShaderInjectData {
  float ao_radius;
  float ao_radius_scale;
  float ao_falloff_range;
  float ao_distribution_power;

  float ao_thin_occluder;
  float ao_gamma;
  float ao_temporal_frame;
  float ao_mip_bias;

  float ao_direction_count;
  float ao_step_count;
  float ao_normal_attenuation;
  float ao_bitmask;

  float ao_thickness;
  float ao_denoiser_blur_beta;
  float pad1;
  float pad2;
};

#ifndef __cplusplus
/*
  We need to account for the padding of the original struct
  (Aux size is 120 bytes & Setting is 8 bytes). Vulkan adjustments
  will add the correct offset when pushing constants,
  but we still need to define the proper offset
  to account for the original game/emulator push constants.

  IMPORTANT: AUX SIZE WILL BECOME 128 Bytes because alignment depends on the largest
  element within the struct. Aux Data has uvec4 which is 16 bytes, so total size will
  have to be aligned to 16. Settings largest element is 4 bytes so it aligns to 4 bytes,
  so final size will be 8. This is important for offsets and will mess up cbuffers unless
  they're manually aligned. You can use define DEBUG_LEVEL_1/DEBUG_LEVEL_2 and renodx will
  log the injection offset
  e.g. utils::constants::PushShaderInjections(layout: 0x0165a600000165a6[2], dispatch: true, resource_tag: -1, offset: 4) <- Might look different
  Offset here is 4(in float4) so it is 16

  PUSH CONSTANTS TOTAL SIZE LIMIT IS 256 BYTES! You can't add cbuffers willy nilly.
  Log should show a warning if it overflows
*/
layout(push_constant) uniform PushData {
  float ao_radius;
  float ao_radius_scale;
  float ao_falloff_range;
  float ao_distribution_power;

  float ao_thin_occluder;
  float ao_gamma;
  float ao_temporal_frame;
  float ao_mip_bias;

  float ao_direction_count;
  float ao_step_count;
  float ao_normal_attenuation;
  float ao_bitmask;

  float ao_thickness;
  float ao_denoiser_blur_beta;
  float pad1;
  float pad2;
}
shader_injection;

#define AO_GAMMA              shader_injection.ao_final_gamma

#endif
#endif  // SRC_BLOODBORNE_SHARED_H_
