//
//  shadersCubo.metal
//  p4
//
//  Created by Alejandro Garcia on 19/2/23.
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




[[vertex]] VertexOutput vertexShaderCubo(
    const device VertexInput *vertexArray[[buffer(0)]],
    constant ArgumentDataCuboRotacion&  argumentData [[ buffer(1) ]],
    unsigned int vid [[vertex_id]])
{

    VertexInput input = vertexArray[vid];
    VertexOutput output;
    
//    // note that we read the multiplication from right to left
//    float fAngulo;
//
//    fAngulo = argumentData.rotationAngle1;
//   // float fLoopDuration = argumentData.loopDuration;
//    float fcos = cos(fAngulo);
//    float fsin = sin(fAngulo);
    
//    //Matriz transformacion
//    let x = simd_double4(x: 10, y: 20, z: 30, w: 40)
//
//    float4x4 matrizRotacion = float
//    func makeRotationMatrix(angle: Float) -> simd_float3x3 {
//        let rows = [
//            simd_float3(cos(angle), -sin(angle), 0),
//            simd_float3(sin(angle), cos(angle), 0),
//            simd_float3(0,          0,          1)
//        ]
//
//        return float3x3(rows: rows)
//    }
//
//    //Matriz de rotacion
//    float4x4 m_eje_z = float4x4 (
//                           float4(fcos, -fsin,  0, 0),
//                           float4(fsin,  fcos,  0, 0),
//                           float4(0,        0,  1, 0),
//                           float4(0,        0,  0, 1)
//                           );
//
//    //Matriz de rotacion
//    float4x4 m_eje_x = float4x4 (
//                           float4(1, 0,    0, 0),
//                           float4(0, fcos,  -fsin, 0),
//                           float4(0, fsin,  fcos, 0),
//                           float4(0, 0,     0, 1)
//                           );
//
//    //Matriz de rotacion
//    float4x4 m_eje_y = float4x4 (
//                           float4(fcos, 0,    fsin, 0),
//                           float4(0, 1,  0, 0),
//                           float4(-fsin, 0,  fcos, 0),
//                           float4(0, 0,     0, 1)
//                           );
    
   // float4 vertice = input.position;
    
  //  float4 nuevoVertice =  m_eje_z*m_eje_x*m_eje_y*vertice;
    //float4 nuevoVertice =  m_eje_y * m_eje_z*vertice;
    
//    glm::mat4 trans = glm::mat4(1.0f);
//    trans = glm::translate(trans, glm::vec3(0.5f, -0.5f, 0.0f));
//    trans = glm::rotate(trans, (float)glfwGetTime(), glm::vec3(0.0f, 0.0f, 1.0f));
//
    
    //output.position = nuevoVertice;
    
   // output.position =  argumentData.projection * argumentData.modelview * nuevoVertice;
    output.position =  argumentData.projection * argumentData.modelview * input.position;
    //output.position =  argumentData.projection * input.position;
    //output.position =  argumentData.modelview * input.position;
    //output.position = input.position;
    //output.position = input.position;
    output.color = input.color;
    return output;
}



[[vertex]] VertexOutput vertexShaderCuboRotacionPosicion(
    const device VertexInput *vertexArray[[buffer(0)]],
    constant ArgumentDataCuboRotacion&  argumentData [[ buffer(1) ]],
    unsigned int vid [[vertex_id]])
{

    VertexInput input = vertexArray[vid];
    VertexOutput output;
    
    float fAngulo;
    fAngulo = argumentData.rotationAngle1;
    float fcos = cos(fAngulo);
    float fsin = sin(fAngulo);
    
//    //Matriz transformacion
//    let x = simd_double4(x: 10, y: 20, z: 30, w: 40)
//
//    float4x4 matrizRotacion = float
//    func makeRotationMatrix(angle: Float) -> simd_float3x3 {
//        let rows = [
//            simd_float3(cos(angle), -sin(angle), 0),
//            simd_float3(sin(angle), cos(angle), 0),
//            simd_float3(0,          0,          1)
//        ]
//
//        return float3x3(rows: rows)
//    }
//
    //Matriz de rotacion
    float4x4 m_eje_z = float4x4 (
                           float4(fcos, -fsin,  0, 0),
                           float4(fsin,  fcos,  0, 0),
                           float4(0,        0,  1, 0),
                           float4(0,        0,  0, 1)
                           );
    
    //Matriz de rotacion
    float4x4 m_eje_x = float4x4 (
                           float4(1, 0,    0, 0),
                           float4(0, fcos,  -fsin, 0),
                           float4(0, fsin,  fcos, 0),
                           float4(0, 0,     0, 1)
                           );
    
    //Matriz de rotacion
    float4x4 m_eje_y = float4x4 (
                           float4(fcos, 0,    fsin, 0),
                           float4(0, 1,  0, 0),
                           float4(-fsin, 0,  fcos, 0),
                           float4(0, 0,     0, 1)
                           );
    
    float4 vertice = input.position;
    float4 nuevoVertice =  m_eje_z*vertice;
     
    //output.position = nuevoVertice;
    output.position = input.position;
    output.color = input.color;
        
    return output;
}


[[fragment]] float4 fragmentShaderCubo(VertexOutput input [[stage_in]])
{
    return input.color;
}
