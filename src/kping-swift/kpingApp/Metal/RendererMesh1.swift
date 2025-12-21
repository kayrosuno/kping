//
//  RendererMesh.swift
//  p4
//
//  Created by Alejandro Garcia on 31/1/23.
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
import MetalKit
import GLKit


class RendererMesh1: NSObject, MTKViewDelegate
{
#if os(macOS)
    var parent: MetalViewMac
#else
    var parent: MetalViewIOS
#endif
   
    var metalDevice: MTLDevice?
    var metalCommandQueue: MTLCommandQueue?
    var pipelineState: MTLRenderPipelineState?
    var vertexBuffer: MTLBuffer?
    var vertexBufferCubo: MTLBuffer?
    var tipoTest: TipoRenderGPU = TipoRenderGPU.Triangle_1
    var aspect:Float = 1.0  // Width / height
    
    /// POsicion de la camara incial
    var cameraPos   = simd_float3(0.35, 0.5,  1.0)    //BUenas var cameraPos   = simd_float3(0.5, 0.6,  1.4)
    var cameraFront = simd_float3(0.0, 0.0, -1.0)
    var cameraUp    = simd_float3(0.0, 1.0,  0.0)
    var yaw:Float   = -90.0
    var pitch:Float = 0.0
    var fov:Float = 45.0
    
   // var contador: Float = 0.0
    var loopDurationX: Float = 120.0 //en seg
    var loopDurationZ: Float = 80.0 //en seg
    var initialTime = uptime()
    var lastFrame = uptime()
    var pipelineDescriptor: MTLRenderPipelineDescriptor?
    var library: MTLLibrary?
    var mesh: MTKMesh?
    
  
    
    #if os(macOS)
    init(_ parent: MetalViewMac, tipoTest: TipoRenderGPU) {
        self.parent = parent
        self.tipoTest = tipoTest
        super.init()
        initPipeLine()
    }
    #else
     init(_ parent: MetalViewIOS, tipoTest: TipoRenderGPU) {
         self.parent = parent
         self.tipoTest = tipoTest
         super.init()
         initPipeLine()
   
    }
    #endif
    
    
    //
    //Inicializacion conjunta del pipeline
    func initPipeLine()  {
        do
        {
            //GPU Device
            if let metalDevice = MTLCreateSystemDefaultDevice()
            {
                self.metalDevice = metalDevice
            }
            
            //Command Queue
            self.metalCommandQueue = metalDevice!.makeCommandQueue()!
            
            // Library de shaders
            library = metalDevice?.makeDefaultLibrary()
            
            // Buffer para Mesh
            let allocator = MTKMeshBufferAllocator(device:  self.metalDevice!)
            
            // Crear un modelo mesh, una esfera
            let mdlMesh = MDLMesh(sphereWithExtent: [0.75, 0.75, 0.75],
                                  segments: [100, 100],
                                  inwardNormals: false,
                                  geometryType: .triangles,
                                  allocator: allocator)
            
            // Pasar el modelo a una vista de MetalKit
            mesh = try MTKMesh(mesh: mdlMesh, device: self.metalDevice!)
        
         
            //PipelineDescriptor
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexMesh1")
            pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentMesh1")
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            pipelineDescriptor.vertexDescriptor =  MTKMetalVertexDescriptorFromModelIO(mesh!.vertexDescriptor) //A MTLVertexDescriptor object is used to configure how vertex data stored in memory is mapped to attributes in a vertex shader.
            
    
            try pipelineState = (metalDevice?.makeRenderPipelineState(descriptor: pipelineDescriptor))!
            
            
        }
        catch {
            print(error)
        }
        
            
    }
  
    //Actualización de la vista, el tamaño por ejemplo
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    
        aspect = Float(size.width / size.height)
    }
    
    //
    //MARK: DRAW METHODS
    //
    func draw(in view: MTKView) {
        switch(tipoTest)
        {
            default:
            draw_mesh(in: view)
        }
    }
    
  
    //MARK: DRAW MESH
    @MainActor
    func draw_mesh(in view: MTKView)
    {
        //1. Drawable
        guard let drawable = view.currentDrawable else
        {
            return
        }
        
        //2. Crear CommandBuffer
        guard let commandBuffer = metalCommandQueue!.makeCommandBuffer() else
        {fatalError("MetalView draw(): error, no hay commandBuffer")}
        
        //3. RenderPassDescriptor
        guard let renderPassDescriptor =  view.currentRenderPassDescriptor else
        {fatalError("MetalView draw(): error, no hay renderpassDescriptor")}
        
        //4. Render Command Encoder
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else
        {fatalError("MetalView draw(): error, no hay renderEncoder")}
        
        //Set render state and resources.
        renderEncoder.setRenderPipelineState(pipelineState!)
        renderEncoder.setVertexBuffer(mesh?.vertexBuffers[0].buffer, offset: 0, index: 0)
        //renderEncoder.setBlendColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)

        guard let submesh = mesh!.submeshes.first else {
          fatalError()
        }
        
        //let angulo: Float = Float(Date.now.timeIntervalSince1970 - initialTime).truncatingRemainder(dividingBy: loopDuration)
        let anguloX: Float = Float((360 / loopDurationX / 100) * Float(uptime() - initialTime)).truncatingRemainder(dividingBy: 360)
        //print("AnguloX: \(anguloX)")
      
        let anguloZ: Float = Float((360 / loopDurationZ / 100) * Float(uptime() - initialTime)).truncatingRemainder(dividingBy: 360)
       // print("AnguloZ: \(anguloZ)")
      
        //Matrix uniforms
        let xAxis = simd_float4(1, 0, 0 , 0)
        let yAxis = simd_float4(0, -1, 0 , 0)
        let zAxis = simd_float4(0, 0, -0.8 , 0)
        
        //Check Mouse, controles de navegacion con mouse o con touch
        check_mouse()
        
        //Matriz identidad
        let matrix_id = matrix_identity_float4x4
        var matrix_model_rot = MatrixFunctions.rotationAboutAxis(zAxis, byAngle: anguloZ)
        let matrix_model_scale =  MatrixFunctions.makeScaleMatrix(xScale: 0.2, yScale: 0.2)
        matrix_model_rot =  matrix_model_rot * matrix_model_scale * matrix_id
        let matrix_perspective = MatrixFunctions.perspectiveProjection(aspect, fieldOfViewY: self.fov, near: 0.01, far: 100.0)
        //makeScaleMatrix(xScale: 0.5, yScale: 0.5)
        
        // var Time = Date.now.timeIntervalSince1970  * 1000
        let currentFrame = uptime()
        let deltaTime = Float(currentFrame - lastFrame)
        let cameraSpeed = Float(0.5) * deltaTime
        lastFrame = currentFrame
        
        if (Keyboard.IsKeyPressed(KeyCodes.w) || Keyboard.IsKeyPressed(KeyCodes.upArrow) )
        {
            cameraPos += cameraSpeed * cameraFront
            //print("W")
        }
        if (Keyboard.IsKeyPressed(KeyCodes.s) || Keyboard.IsKeyPressed(KeyCodes.downArrow) )
        {
            cameraPos -= cameraSpeed * cameraFront
            //print("S")
        }
        if (Keyboard.IsKeyPressed(KeyCodes.a) || Keyboard.IsKeyPressed(KeyCodes.leftArrow) )
        {
           //  cameraPos -= glm::normalize(glm::cross(cameraFront, cameraUp)) * cameraSpeed;
            cameraPos -= simd_normalize(simd_cross(cameraFront, cameraUp)) * cameraSpeed
            
        }
        if (Keyboard.IsKeyPressed(KeyCodes.d) || Keyboard.IsKeyPressed(KeyCodes.rightArrow) )
        {
           // cameraPos += glm::normalize(glm::cross(cameraFront, cameraUp)) * cameraSpeed;
            cameraPos += simd_normalize(simd_cross(cameraFront, cameraUp)) * cameraSpeed
        }
        
    
        
        let cameraCenter = cameraPos + cameraFront
        let view = GLKMatrix4MakeLookAt(cameraPos.x, cameraPos.y, cameraPos.z,
                                        cameraCenter.x, cameraCenter.y, cameraCenter.z,
                                        cameraUp.x, cameraUp.y, cameraUp.z)
        
     
        let view_x = simd_float4(view.m00,view.m01,view.m02,view.m03)
        let view_y = simd_float4(view.m10,view.m11,view.m12,view.m13)
        let view_z = simd_float4(view.m20,view.m21,view.m22,view.m23)
        let view_w = simd_float4(view.m30,view.m31,view.m32,view.m33)
        let view_camera = simd_float4x4(view_x, view_y, view_z, view_w)

              
        var argument = ArgumentDataMesh( rotationAngleX: anguloX,  rotationAngleZ: anguloZ, projection: matrix_perspective, modelview: view_camera)//*matrix_model_rot)
        
        renderEncoder.setVertexBytes(&argument, length: MemoryLayout<ArgumentDataMesh>.stride, index: 1)
        
        //Draw
        renderEncoder.drawIndexedPrimitives(type: .lineStrip,
                                  indexCount: submesh.indexCount,
                                  indexType: submesh.indexType,
                                  indexBuffer: submesh.indexBuffer.buffer,
                                  indexBufferOffset: 0)
     
        
        // END encoding your onscreen render pass.
        renderEncoder.endEncoding()
        
        // Register the drawable's presentation.
        commandBuffer.present(drawable)
        
        // Finalize your onscreen CPU work and commit the command buffer to a GPU.
        commandBuffer.commit()
    }

    
    // Verifica movimientos del mouse
    @MainActor
    func check_mouse()
    {
        //Check Scroll
        fov -= Mouse.GetDWheel() //yoffset;
        if (fov < 1.0) {
            fov = 1.0
        }
        if (fov > 45.0) {
            fov = 45.0
        }
        
        
        //Check button left and movement
        if ( Mouse.IsMouseButtonPressed(button: MouseCodes.left) )
        {
            var xoffset = Mouse.GetDX()
            var yoffset = Mouse.GetDY()
            var sensitivity:Float = 0.1
            xoffset *= sensitivity
            yoffset *= sensitivity

            yaw   += xoffset
            pitch -= yoffset

            if(pitch > 89.0) {
                pitch = 89.0
            }
            if(pitch < -89.0) {
                pitch = -89.0
            }

            var direction = SIMD3<Float>()
            direction.x = cos(GLKMathDegreesToRadians(yaw)) * cos(GLKMathDegreesToRadians(pitch))
            direction.y = sin(GLKMathDegreesToRadians(pitch))
            direction.z = sin(GLKMathDegreesToRadians(yaw)) * cos(GLKMathDegreesToRadians(pitch))
            cameraFront = normalize(direction);
            
        }
    }
}
    
