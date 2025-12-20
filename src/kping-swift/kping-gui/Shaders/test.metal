//
//  test.metal
//  metalTest1
//
//  Created by Alejandro Garcia on 7/1/23.
//
//  Copyright © 2023-2024 Alejandro Garcia <iacobus75@gmail.com>  <alejandro@kayros.uno>
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#include <metal_stdlib>
using namespace metal;
#include "definitions.metal"

/**  Funcion que suma dos arrys*/
kernel void add_arrays(device const float* inA,
                       device const float* inB,
                       device float* result,
                       uint index [[thread_position_in_grid]])
{
    // the for-loop is replaced with a collection of threads, each of which
    // calls this function.
    result[index] = inA[index] + inB[index];
}


//
//vertex VertexOut myVertexShader(const global Vertex* vertexArray [[ buffer(0) ]], unsigned int vid [[ vertex_id ]]) {
//    VertexOut out;
//    out.position = vertexArray[vid].position;
//    out.color = vertexArray[vid].color;
//    return out;
//}
//
//fragment float4 myFragmentShader(VertexOut interpolated [[stage_in]])
//{
//    return interpolated.color;
//}
//
//struct Uniforms {
//    float4x4 mvp_matrix;
//};
//
//vertex VSOut vertexShader(const global Vertex* vertexArray [[ buffer(0) ]], constant Uniforms& uniforms [[ buffer(1) ]],unsigned int vid [[ vertex_id]]) {
//    VSOut out;
//    out.position = uniforms.mvp_matrix * vertexArray[vid].position;
//    out.color = half4(vertexArray[vid].color);
//    return out;
//}
