//
//  shadersMesh.metal
//  p4
//
//  Created by Alejandro Garcia on 26/2/23.
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

//MARK: MESH1
//Vertex shader
[[vertex]] VertexOutput vertexMesh1(const VertexInMesh vertex_in [[ stage_in ]],
    constant ArgumentDataMesh  &argumentData [[ buffer(1) ]],
    unsigned int vid [[vertex_id]])
{

    //VertexInput input = vertex_in[vid];
    VertexOutput output;
    
   
    
    //Angulo de rotacion X
    float fAnguloX;
    fAnguloX = argumentData.rotationAngleX;
    float fcosX = cos(fAnguloX);
    float fsinX = sin(fAnguloX);
    
    //Angulo de rotacion Z
    float fAnguloZ;
    fAnguloZ = argumentData.rotationAngleZ;
    float fcosZ = cos(fAnguloZ);
    float fsinZ = sin(fAnguloZ);
    
    
    //Rotacion
    //Matriz de rotacion
    float4x4 m_eje_z = float4x4 (
                           float4(fcosZ, -fsinZ,  0, 0),
                           float4(fsinZ,  fcosZ,  0, 0),
                           float4(0,        0,  1, 0),
                           float4(0,        0,  0, 1)
                           );
    
    //Matriz de rotacion
    float4x4 m_eje_x = float4x4 (
                           float4(1, 0,    0, 0),
                           float4(0, fcosX,  -fsinX, 0),
                           float4(0, fsinX,  fcosX, 0),
                           float4(0, 0,     0, 1)
                           );
    
    //Matriz de rotacion
    float4x4 m_eje_y = float4x4 (
                           float4(fcosX, 0,    fsinX, 0),
                           float4(0, 1,  0, 0),
                           float4(-fsinX, 0,  fcosX, 0),
                           float4(0, 0,     0, 1)
                           );
    
    float4 vertice = vertex_in.position;
    //float4 nuevoVertice =  m_eje_z*vertice;
    float4 nuevoVertice =  m_eje_x*m_eje_z*vertice;
     
    //output.position = nuevoVertice;
    //output.position =  argumentData.projection * argumentData.modelview * vertex_in.position;
    output.position =  argumentData.projection * argumentData.modelview * nuevoVertice;
    
    
//    output.position = vertex_in.position;
    //output.color = vertex_in.color;
      
    
    //Color
    float fcolor = vid / 10000.0;
    float4 f4_color = float4(1-fcolor, 0, 0+fcolor, 1);
    
    output.color = f4_color;
    return output;
}


//Fragment shader
[[fragment]] float4 fragmentMesh1(VertexOutput input [[stage_in]]) {
  
    return input.color;
}


//MARK: MESH2

//Vertex shader
[[vertex]] VertexOutput vertexMesh2(const VertexInMesh vertex_in [[ stage_in ]],
    constant ArgumentDataMesh  &argumentData [[ buffer(1) ]],
    unsigned int vid [[vertex_id]])
{

    VertexOutput output;
    
    output.position =  argumentData.projection * argumentData.modelview * vertex_in.position;
    
    float fcolor = vid / 10000.0;
    float4 f4_color = float4(1-fcolor/2, 0.7-fcolor, 0+fcolor, 1);
    
    output.color = f4_color;
    return output;
}


//Fragment shader
[[fragment]] float4 fragmentMesh2(VertexOutput input [[stage_in]]) {
  
    return input.color;
}
