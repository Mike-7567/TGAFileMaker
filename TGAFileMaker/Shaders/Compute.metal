//
//  Compute.metal
//  TGAFileMaker
//
//  Created by Gabriel Thomson on 8/5/26.
//

#include <metal_stdlib>
using namespace metal;

kernel void combineTextures(uint2 index [[thread_position_in_grid]], texture2d<float, access::sample> roughness [[texture(0)]], texture2d<float, access::sample> emissive [[texture(1)]], texture2d<float, access::sample> metalness [[texture(2)]], texture2d<float, access::write> output [[texture(3)]]) {
    
    float r = metalness.read(index).r;
    float g = emissive.read(index).g;
    float b = roughness.read(index).b;
    
    output.write(float4(r, g, b, 1), index);
}
