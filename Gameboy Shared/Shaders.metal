//
//  Shaders.metal
//  Gameboy Shared
//
//  Created by Wittawin Muangnoi on 1/7/2568 BE.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "ShaderTypes.h"

using namespace metal;

typedef struct
{
    float3 position [[attribute(VertexAttributePosition)]];
    float2 texCoord [[attribute(VertexAttributeTexcoord)]];
} Vertex;

typedef struct
{
    float4 position [[position]];
    float2 texCoord;
} ColorInOut;

struct VertexOut
{
  float4 position [[ position ]];
  float2 texcoord;
};

constexpr sampler sampler2D = sampler(coord::normalized, filter::nearest);

vertex VertexOut vertex_shader(const device float2* vertexArray [[ buffer(0) ]],
                               unsigned int         vid         [[ vertex_id ]])
{
  VertexOut out;
  out.position = float4(vertexArray[vid], 0.0, 1.0);
  out.texcoord = float2((vertexArray[vid] + 1) * 0.5);
  out.texcoord.y = 1.0 - out.texcoord.y; // so we start in upper left corner
  return out;
}

fragment half4 fragment_shader(VertexOut          interpolated [[ stage_in ]],
                               texture2d<ushort>  tex2D        [[ texture(0) ]])
{
  // GameBoy uses:
  // 0 - White
  // 1 - Light gray
  // 2 - Dark gray
  // 3 - Black
  // We need to 'correct' this.

  float raw = tex2D.sample(sampler2D, interpolated.texcoord).r;
  float corrected = 3 - raw;
  float rgb = corrected * 0.33; // to convert to <0, 1> space

  return half4(rgb, rgb, rgb, 1.0);
}

vertex ColorInOut vertexShader(Vertex in [[stage_in]],
                               constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]])
{
    ColorInOut out;

    float4 position = float4(in.position, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    out.texCoord = in.texCoord;

    return out;
}

fragment float4 fragmentShader(ColorInOut in [[stage_in]],
                               constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]],
                               texture2d<half> colorMap     [[ texture(TextureIndexColor) ]])
{
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear);

    half4 colorSample   = colorMap.sample(colorSampler, in.texCoord.xy);

    return float4(colorSample);
}
