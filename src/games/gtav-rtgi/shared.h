#ifndef SRC_TEMPLATE_SHARED_H_
#define SRC_TEMPLATE_SHARED_H_

// Must be 32bit aligned
// Should be 4x32
struct ShaderInjectData {
  float gUseSkyBounce;
  float gRayDistSkyBounce;
  float gRoughnessThreshold;	//0.29
  float gSpecIntensityThreshold;	//0.30
  
  float gUseAtomsphere;
  float gDebugFull;
  float gJitterReflection;
  float gArtificialAmbientScale;
};

#ifndef __cplusplus
cbuffer shader_injection : register(b13, space50) {
  ShaderInjectData shader_injection : packoffset(c0);
}
#endif 

#endif  // SRC_TEMPLATE_SHARED_H_
