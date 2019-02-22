//
//  shaders.metal
//  Metal-ScreenSaver
//
//  Created by Antoine FEUERSTEIN on 2/19/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#define NUM_PARTICLES 13.0

static float3 particles(float2 uv, float3 color, float radius, float offset, float time)
{
    //float2 position = float2(sin(offset * (time + 1.0)) * 1, sin(offset * (time + 1.5 * sin(time)))) * (cos(time - sin(offset)) * atan(offset * 1));
    float2 position = float2(sin(offset * (time + 1.0)), sin(offset * (time + 1.0 * sin(time)))) * (cos(time - sin(offset)) * atan(offset * 1));
    float dist = radius / distance(uv, position);
    
    return color * pow(dist, 0.7);
}

kernel void compute_function(texture2d<float, access::write> texture [[texture(0)]], uint2 gid [[thread_position_in_grid]], device const float &time [[buffer(0)]]) {
    float2 size = float2(texture.get_width(), texture.get_height());
    float2 uv = (float2(gid) - (-0.25 * (cos((time + 1.0))) * cos(time * atan(1.0)) + 0.55) * size) / size.y;
    float3 color = float3(((sin(time * 0.15) + 0.05) * 0.4), ((sin(time * 0.14) + 0.00) * 0.4), ((sin(time * 2.0) + 0.05) * 0.4));
    float3 pixel = float3(0);
    float radius = clamp(abs(0.008 * sin(time)), 0.002, 1.0);
    
    for (float i = 0.0; i < NUM_PARTICLES; i++)
    {
        pixel += abs(particles(uv, color, radius, i / NUM_PARTICLES, time));
    }
    texture.write(mix(float4(uv, 0.8 + 0.5 * cos(time), 1.0), float4(pixel, 1.0), 0.8), gid);
}
