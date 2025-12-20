//
//  shadersTriangle.metal
//  p4
//
//  Created by Alejandro Garcia on 2/2/23.
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
//#include "definitions.h"
using namespace metal;
#include "definitions.metal"




[[vertex]] VertexOutput vertexShader(const device VertexTriangle *vertexArray[[buffer(0)]],
                                    // constant argumentData&  argumentData [[buffer(1)]],
                             unsigned int vid [[vertex_id]])
{
    VertexTriangle input = vertexArray[vid];
    VertexOutput output;
    output.position = float4(input.position.x,//+argumentData.loopDuration,
                             input.position.y, 0 , 1);
    output.color = input.color;
    
    return output;
}




[[vertex]] VertexOutput vertexShaderRotacionPosicion(const device VertexTriangle *vertexArray[[buffer(0)]],
    constant ArgumentDataRotacion&  argumentData [[ buffer(1) ]],
    unsigned int vid [[vertex_id]])
{

    VertexTriangle input = vertexArray[vid];
    VertexOutput output;
    
    float fAngulo;
    if(vid >2)
        fAngulo = argumentData.rotationAngle2;
    else
        fAngulo = argumentData.rotationAngle1;
   // float fLoopDuration = argumentData.loopDuration;
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
    
    //float4 nuevoVertice =  m_eje_z*m_eje_x*m_eje_y*vertice;
    float4 nuevoVertice =  m_eje_z*vertice;
    
//    glm::mat4 trans = glm::mat4(1.0f);
//    trans = glm::translate(trans, glm::vec3(0.5f, -0.5f, 0.0f));
//    trans = glm::rotate(trans, (float)glfwGetTime(), glm::vec3(0.0f, 0.0f, 1.0f));
//
    
    output.position = nuevoVertice;
    
    if(vid >2)
    {
        output.color.r = input.color.r;
        output.color.g = input.color.g;
        output.color.b = input.color.b;
        output.color.a = 0.6f;
    }
    else
        output.color = input.color;
        
    return output;
}



[[vertex]] VertexOutput vertexShaderRotacionColor(const device VertexTriangle *vertexArray[[buffer(0)]],
    constant ArgumentDataColor&  argumentData [[ buffer(1) ]],
    unsigned int vid [[vertex_id]])
{

       /* float timeScale = 3.14159f * 2.0f / argumentData.loopDuration;
        float currTime = fmod(argumentData.time, argumentData.loopDuration);
        
        VertexInput input = vertexArray[vid];
        VertexOutput output;
        
        float4 totalOffset = float4(cos(currTime * timeScale) * 0.5f,
                                    sin(currTime * timeScale) * 0.5f,
                                    0.0f,
                                    0.0f);
        
        output.position = input.position + totalOffset;
        output.color = input.color;
        
        return output;
        */
        
    VertexTriangle input = vertexArray[vid];
        VertexOutput output;
        output.position = float4(input.position.x,
                                 input.position.y,
                                 input.position.z, 1);

    switch (input.vid)
    {
       case 0:
        //	Color, rotation on each call
//        if(argumentData.shiftColor <= 1.0)
//        {
//            output.color.r = argumentData.shiftColor;
//            output.color.g = 0;
//            output.color.b = 0 ;
//        }
//        else if(argumentData.shiftColor > 1.0 && argumentData.shiftColor <= 2.0)
//        {
//            output.color.r = 1 - (argumentData.shiftColor-1);
//            output.color.g = (argumentData.shiftColor-1);
//            output.color.b = 0 ;
//        }
//
//        else {
//            output.color.r = 0;
//            output.color.g = 1 - (argumentData.shiftColor-2);
//            output.color.b = -1 + (argumentData.shiftColor-2);
//        }
            output.color.r = argumentData.shiftColor ;
            output.color.g = argumentData.shiftColor > 1 ? argumentData.shiftColor-1 : 0;
            output.color.b = argumentData.shiftColor > 2 ? argumentData.shiftColor-2 : 0;
            output.color.a = input.color.a;
            break;
        case 1:
            output.color.r = argumentData.shiftColor ;
            output.color.g = argumentData.shiftColor > 1 ? (argumentData.shiftColor - 1) : 0;
            output.color.b = argumentData.shiftColor > 2 ? argumentData.shiftColor-2 : 0;
            output.color.a = input.color.a;
            break;
        case 2:
            output.color.r = argumentData.shiftColor > 2 ? argumentData.shiftColor-2 : 0;
            output.color.g = argumentData.shiftColor > 2 ? argumentData.shiftColor-2 : 0;
            output.color.b = argumentData.shiftColor ;
            output.color.a = input.color.a;
            break;

        default:
            output.color = input.color;
    }

    return output;
}




[[vertex]] VertexOutput vertexShaderRotacionColorPosicion(const device VertexTriangle *vertexArray[[buffer(0)]],
    constant ArgumentDataColor&  argumentData [[ buffer(1) ]],
    unsigned int vid [[vertex_id]])
{

    VertexTriangle input = vertexArray[vid];
        VertexOutput output;
        output.position = float4(input.position.x+argumentData.shiftColor,
                                 input.position.y,
                                 input.position.z, 1);

    switch (input.vid)
    {
       case 0:
            output.color.r = argumentData.shiftColor ;
            output.color.g = argumentData.shiftColor > 1 ? argumentData.shiftColor-1 : 0;
            output.color.b = argumentData.shiftColor > 2 ? argumentData.shiftColor-2 : 0;
            
            break;
        case 1:
            output.color.r = argumentData.shiftColor ;
            output.color.g = argumentData.shiftColor > 1 ? (argumentData.shiftColor - 1) : 0;
            output.color.b = argumentData.shiftColor > 2 ? argumentData.shiftColor-2 : 0;
            break;
        case 2:
            output.color.r = argumentData.shiftColor > 2 ? argumentData.shiftColor-2 : 0;
            output.color.g = argumentData.shiftColor > 2 ? argumentData.shiftColor-2 : 0;
            output.color.b = argumentData.shiftColor ;
            break;

        default:
            output.color = input.color;
    }

    return output;
}

                             
[[fragment]] float4 fragmentShader(VertexOutput input [[stage_in]])
{
    return input.color;
}

[[fragment]] float4 fragmentShaderConAlfa(VertexOutput input [[stage_in]])
{
    //Este shader de fragmento o pixel, devuelve el color con alfa
    
  
    float4 outputColor = input.color;

    outputColor.a = 0.6;  //Si baja a 0.5 no se muestra!! porque!!!!
    
    return outputColor;
    
}

[[fragment]] float4 fragmentShaderWhiteScale(VertexOutput input [[stage_in]])
{
    //Este shader de fragmento o pixel, devuelve una escala de color dependiento de lo lejos que este el punto de la base
    
    float lerpValue = input.position.y / 1000.0f;
    float4 outputColor = mix(  float4(0.2f, 0.2f, 0.2f, 1.0f), float4(1.0f, 1.0f, 1.0f, 1.0f), lerpValue);

    return outputColor;
}

//
//vertex VertexOutput2
//render_vertex(const device VertexInputData *v_in [[buffer(0)]],
//constant float4x4& mvp_matrix [[buffer(1)]],
//constant LightDesc& lights [[buffer(2)]],
//uint v_id [[vertex_id]])
//{
//VertexOutput v_out;
//v_out.position = v_in[v_id].position * mvp_matrix;
//v_out.color = do_lighting(v_in[v_id].position,
//v_in[v_id].normal, lights);
//v_out.texcoord = v_in[v_id].texcoord;
//return v_out;
//}
//fragment float4
//render_pixel(VertexOutput2 input [[stage_in]],
//texture2d<float> imgA [[texture(0)]],
//texture2d<float> imgB [[texture(1)]])
//{
//float4 tex_clr0 = imgA.sample(s, input.texcoord);
//float4 tex_clr1 = imgB.sample(s, input.texcoord);
//// Compute color.
//float4 clr = compute_color(tex_clr0, tex_clr1, …);
//return
