//
//  definitions.metal
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
#include <simd/simd.h>

using namespace metal;


//Argument Data
struct ArgumentData
{
    float loopDuration;
    int time;
};

//Rotacion
struct ArgumentDataRotacion
{
    float rotationAngle1;
    float rotationAngle2;
};



//Rotacion Cubo
struct ArgumentDataCuboRotacion
{
    float rotationAngle1;
    simd_float4 cuboColor;
    simd_float4 lightPosicion;
    simd_float3 reflectivity;
    simd_float3 intensity;
    simd_float4x4  projection;
    simd_float4x4  modelview;
   
};



//Rotacion Cubo
struct ArgumentDataMesh
{
    float rotationAngleX;
    float rotationAngleZ;
    simd_float4 lightPosicion;
    simd_float3 reflectivity;
    simd_float3 intensity;
    simd_float4x4  projection;
    simd_float4x4  modelview;
};

//Rotacion Color
struct ArgumentDataColor
{
    float shiftColor;
   
};

struct VertexTriangle {
    vector_float4 position;
    vector_float3 normal;
    vector_float4 color;
    uint vid;
};

struct VertexOutput {
    vector_float4 position [[position]];
    vector_float4 color;
};

struct VertexInput {
    vector_float4 position;
    vector_float3 normal;
    vector_float4 color;
    uint vid;
};

struct VertexInMesh {
  float4 position [[ attribute(0) ]];
};

