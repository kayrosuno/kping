//
//  Utilidades.swift
//  p4
//
//  Created by Alejandro Garcia on 25/2/23.
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

import Foundation
import simd



actor actorTaskData
{
    var runningGPU = false
    
    func newRunning() -> Bool
    {
        if runningGPU {
            return true
        }
        else
        {
            runningGPU = true
            return false
        }
    }
    
    func stopRunningGPU()
    {
        runningGPU = false
    }
}


//Los tipos de VistaActiva
enum TipoRenderGPU: CaseIterable
{
    case GPUInfo, GPUvsCPU, Triangle_1, Triangle_2, Triangle_3, Cubo_1, Mesh_1, Mesh_2
    
}

// Vertex Struct
struct Vertex
{
    var position:simd_float4
    var normal:simd_float3
    var color:simd_float4
    var vid: uint
}

//Argument Mesh
struct ArgumentDataCuboRotacion
{
    var rotationAngle1: Float
    var cuboColor = simd_float4(0.7, 0.4, 0.18, 1.0)
    var lightPosition = simd_float4 (5.0 , 5.0, 2.0, 1.0)
    var reflectivity = simd_float3(0.9, 0.5, 0.3)
    var intensity = simd_float3( 1.0, 1.0, 1.0)
    var projection: simd_float4x4
    var modelview: simd_float4x4
   // var model: simd_float4x4
}

//Argument Mesh
struct ArgumentDataMesh
{
    var rotationAngleX: Float
    var rotationAngleZ: Float
    var lightPosition = simd_float4 (5.0 , 5.0, 2.0, 1.0)
    var reflectivity = simd_float3(0.9, 0.5, 0.3)
    var intensity = simd_float3( 1.0, 1.0, 1.0)
    var projection: simd_float4x4
    var modelview: simd_float4x4
}



//Angulo de rotación del triangulo
struct argumentDataColor
{
    let rotationAngle1:Float
    let rotationAngle2:Float
//            let loopDuration:Float
//            let shiftColor:Float
//            let time:Int = Int(Date().timeIntervalSince1970*1000)
}
