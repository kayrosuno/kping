//
//  Renderer.swift
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


class RendererTriangle: NSObject, MTKViewDelegate
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
    var tipoTest: TipoRenderGPU = .Triangle_1
    var aspect:Float = 1.0  // Width / height
    var cameraPos   = simd_float3(0.0, 0.0,  3.0)
    var cameraFront = simd_float3(0.0, 0.0, -1.0)
    var cameraUp    = simd_float3(0.0, 1.0,  0.0)
    var yaw   = -90.0
    var pitch = 0.0
    var lastX = 0.0
    var lastY = 0.0
    var fov = 45.0
   // var contador: Float = 0.0
    var loopDuration: Float = 23.0 //en seg
    var initialTime = Date.now.timeIntervalSince1970
    var lastFrame = uptime()
    var pipelineDescriptor: MTLRenderPipelineDescriptor?
    var library: MTLLibrary?
    
    
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
    
    
     //Inicializacion conjunta del pipeline
    func initPipeLine() {
        
        if let metalDevice = MTLCreateSystemDefaultDevice()
        {
            self.metalDevice = metalDevice
        }
        
        self.metalCommandQueue = metalDevice!.makeCommandQueue()!
       
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        library = metalDevice?.makeDefaultLibrary()
        
        
        
        switch(tipoTest)
        {
            
        case .Triangle_3:
            pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexShaderRotacionPosicion")
            pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentShaderConAlfa")
            pipelineDescriptor.isAlphaToCoverageEnabled = true
       
        case .Cubo_1:
            pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexShaderCubo")
            pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentShaderCubo")
            //pipelineDescriptor.isAlphaToCoverageEnabled = false
            
                  let verticesCubo =  [
                      //Fondo
                      Vertex(position: [-0.5, -0.5, -0.5, 1], normal: [ 0.0,  0.0, -1.0], color: [1,0,0,1], vid:0 ),
                      Vertex(position: [ 0.5, -0.5, -0.5, 1], normal: [ 0.0,  0.0, -1.0], color: [1,0,0,1], vid:1 ),
                      Vertex(position: [ 0.5,  0.5, -0.5, 1], normal: [ 0.0,  0.0, -1.0], color: [1,0,0,1], vid:2 ),
                      Vertex(position: [ 0.5,  0.5, -0.5, 1], normal: [ 0.0,  0.0, -1.0], color: [1,0,0,1], vid:3 ),
                      Vertex(position: [-0.5,  0.5, -0.5, 1], normal: [ 0.0,  0.0, -1.0], color: [1,0,0,1], vid:4 ),
                      Vertex(position: [-0.5, -0.5, -0.5, 1], normal: [ 0.0,  0.0, -1.0], color: [1,0,0,1], vid:5 ),

                      //Front
                      Vertex(position: [-0.5, -0.5,  0.5, 1], normal: [ 0.0,  0.0, 1.0],  color: [1,1,1,1], vid:6 ),
                      Vertex(position: [ 0.5, -0.5,  0.5, 1], normal: [ 0.0,  0.0, 1.0],  color: [1,1,1,1], vid:7 ),
                      Vertex(position: [ 0.5,  0.5,  0.5, 1], normal: [  0.0,  0.0, 1.0], color: [1,1,1,1], vid:8 ),
                      Vertex(position: [ 0.5,  0.5,  0.5, 1], normal: [  0.0,  0.0, 1.0], color: [1,1,1,1], vid:9 ),
                      Vertex(position: [-0.5,  0.5,  0.5, 1], normal: [  0.0,  0.0, 1.0], color: [1,1,1,1], vid:10 ),
                      Vertex(position: [-0.5, -0.5,  0.5, 1], normal: [ 0.0,  0.0, 1.0],  color: [1,1,1,1], vid:11 ),

                      Vertex(position: [-0.5,  0.5,  0.5, 1], normal: [ -1.0,  0.0,  0.0], color: [0,1,0,1], vid:12 ),
                      Vertex(position: [-0.5,  0.5, -0.5, 1], normal: [ -1.0,  0.0,  0.0], color: [0,1,0,1], vid:13 ),
                      Vertex(position: [-0.5, -0.5, -0.5, 1], normal: [ -1.0,  0.0,  0.0], color: [0,1,0,1], vid:14 ),
                      Vertex(position: [-0.5, -0.5, -0.5, 1], normal: [ -1.0,  0.0,  0.0], color: [0,1,0,1], vid:15 ),
                      Vertex(position: [-0.5, -0.5,  0.5, 1], normal: [ -1.0,  0.0,  0.0], color: [0,1,0,1], vid:16 ),
                      Vertex(position: [-0.5,  0.5,  0.5, 1], normal: [ -1.0,  0.0,  0.0], color: [0,1,0,1], vid:17 ),

                      Vertex(position: [ 0.5,  0.5,  0.5, 1], normal: [ 1.0,  0.0,  0.0],  color: [0,0,1,1], vid:18 ),
                      Vertex(position: [ 0.5,  0.5, -0.5, 1], normal: [ 1.0,  0.0,  0.0],  color: [0,0,1,1], vid:19 ),
                      Vertex(position: [ 0.5, -0.5, -0.5, 1], normal: [  1.0,  0.0,  0.0], color: [0,0,1,1], vid:20 ),
                      Vertex(position: [ 0.5, -0.5, -0.5, 1], normal: [  1.0,  0.0,  0.0], color: [0,0,1,1], vid:21 ),
                      Vertex(position: [ 0.5, -0.5,  0.5, 1], normal: [  1.0,  0.0,  0.0], color: [0,0,1,1], vid:22 ),
                      Vertex(position: [ 0.5,  0.5,  0.5, 1], normal: [  1.0,  0.0,  0.0], color: [0,0,1,1], vid:23 ),

                      Vertex(position: [-0.5, -0.5, -0.5,  1], normal: [ 0.0, -1.0,  0.0], color: [1,1,0,1], vid:24 ),
                      Vertex(position: [ 0.5, -0.5, -0.5,  1], normal: [ 0.0, -1.0,  0.0], color: [1,1,0,1], vid:25 ),
                      Vertex(position: [ 0.5, -0.5,  0.5,  1], normal: [ 0.0, -1.0,  0.0], color: [1,1,0,1], vid:26 ),
                      Vertex(position: [ 0.5, -0.5,  0.5,  1], normal: [ 0.0, -1.0,  0.0], color: [1,1,0,1], vid:27 ),
                      Vertex(position: [-0.5, -0.5,  0.5,  1], normal: [ 0.0, -1.0,  0.0], color: [1,1,0,1], vid:28 ),
                      Vertex(position: [-0.5, -0.5, -0.5,  1], normal: [ 0.0, -1.0,  0.0], color: [1,1,0,1], vid:29 ),

                      Vertex(position: [-0.5,  0.5, -0.5,  1], normal: [ 0.0,  1.0,  0.0], color: [1,0.5,0,1], vid:30 ),
                      Vertex(position: [ 0.5,  0.5, -0.5,  1], normal: [ 0.0,  1.0,  0.0], color: [1,0.5,0,1], vid:31 ),
                      Vertex(position: [ 0.5,  0.5,  0.5,  1], normal: [ 0.0,  1.0,  0.0], color: [1,0.5,0,1], vid:32 ),
                      Vertex(position: [ 0.5,  0.5,  0.5,  1], normal: [ 0.0,  1.0,  0.0], color: [1,0.5,0,1], vid:33 ),
                      Vertex(position: [-0.5,  0.5,  0.5,  1], normal: [  0.0,  1.0,  0.0],color: [1,0.5,0,1], vid:34 ),
                      Vertex(position: [-0.5,  0.5, -0.5,  1], normal: [ 0.0,  1.0,  0.0], color: [1,0.5,0,1], vid:35 )
                  ]

              vertexBufferCubo = (metalDevice?.makeBuffer(bytes: verticesCubo, length: verticesCubo.count * MemoryLayout<Vertex>.stride, options: []))!
        
                
        default:
            pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
            pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
            
             

        }

        
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        //2 triangulos
        let vertices = [
            Vertex(position: [ 0.0,  0.8, 0.0, 1],  normal: [ 0.0,  0.0, 0.0],   color: [1,0,0,1], vid:0 ),
            Vertex(position: [-0.8, -0.8, 0.0, 1],  normal: [ 0.0,  0.0, 0.0],   color: [0,1,0,1], vid:1 ),
            Vertex(position: [ 0.8, -0.8, 0.0, 1],  normal: [ 0.0,  0.0, 0.0],   color: [0,0,1,1], vid:2 ),
            Vertex(position: [ 0.2,  0.9, 0.0, 1],  normal: [ 0.0,  0.0, 0.0],   color: [1,0,0,0.6], vid:0 ),
            Vertex(position: [-0.4, -0.5, 0.0, 1],  normal: [ 0.0,  0.0, 0.0],   color: [0,1,0,0.6], vid:1 ),
            Vertex(position: [ 0.9, -0.4, 0.0, 1],  normal: [ 0.0,  0.0, 0.0],   color: [0,0,1,0.6], vid:2 )
        ]
        
        
        vertexBuffer = (metalDevice?.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: []))!
    

        //Set PipeLineState
        do
        {
            try pipelineState = (metalDevice?.makeRenderPipelineState(descriptor: pipelineDescriptor))!
            
        } catch {
            fatalError()
        }
        
            
    }
  
    //Actualización de la vista, el tamaño por ejemplo
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        //TODO: cambiar tamaño render
        //MTKView.setBoundsSize(  view)
        //self.parent.mtkView.drawableSize = size
        aspect = Float(size.width / size.height)
        //print("New size: \(size.width)  \(size.height)")
        //print("Aspect ratio: \(aspect)")
    }
    
    //
    //MARK: DRAW METHODS
    //
    func draw(in view: MTKView) {
        switch(tipoTest)
        {
            case .Triangle_1:
                draw_triangle1(in: view)
            case .Triangle_2:
                draw_triangle2(in: view)
            case .Triangle_3:
                draw_triangle3(in: view)
            case .Cubo_1:
                draw_cubo(in: view)
        
            
            default:
                draw_triangle1(in: view)
        }
    }
    
    //MARK: draw triangle 1
    //Mark Draw triangle1
    @MainActor
    func draw_triangle1(in view: MTKView)
    {
        
        guard let drawable = view.currentDrawable else
        {
            return
        }
        
        guard let commandBuffer = metalCommandQueue!.makeCommandBuffer()
        else
        {fatalError("MetalView draw(): error, no hay commandBuffer")}
        
        guard let renderPassDescriptor =  view.currentRenderPassDescriptor else
        {fatalError("MetalView draw(): error, no hay renderpassDescriptor")}
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0 , 0 , 1.0)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
      
       
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else
        {fatalError("MetalView draw(): error, no hay renderEncoder")}
        
        //Set render state and resources.
        renderEncoder.setRenderPipelineState(pipelineState!)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        
       
    
        // Issue draw calls.
        //....
        
        // END encoding your onscreen render pass.
        renderEncoder.endEncoding()
        
        // Register the drawable's presentation.
        commandBuffer.present(drawable)
        
        // Finalize your onscreen CPU work and commit the command buffer to a GPU.
        commandBuffer.commit()
    }
    
    //MARK: draw triangle 2
    //Draw triangle2
    @MainActor
    func draw_triangle2(in view: MTKView)
    {
        
        guard let drawable = view.currentDrawable else
        {
            return
        }
        
        guard let commandBuffer = metalCommandQueue!.makeCommandBuffer()
        else
        {fatalError("MetalView draw(): error, no hay commandBuffer")}
        
        guard let renderPassDescriptor =  view.currentRenderPassDescriptor else
        {fatalError("MetalView draw(): error, no hay renderpassDescriptor")}
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.2, 0.2 , 0.2 , 1.0)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
       
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else
        {fatalError("MetalView draw(): error, no hay renderEncoder")}
        
        //Set render state and resources.
        renderEncoder.setRenderPipelineState(pipelineState!)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: 6)
    
        // Issue draw calls.
        //....
        
        // END encoding your onscreen render pass.
        renderEncoder.endEncoding()
        
        // Register the drawable's presentation.
        commandBuffer.present(drawable)
        
        // Finalize your onscreen CPU work and commit the command buffer to a GPU.
        commandBuffer.commit()
    }
    
    //MARK: draw triangle 3
    //Draw triangle3
    @MainActor
    func draw_triangle3(in view: MTKView)
    {
        //1. Drawable
        guard let drawable = view.currentDrawable else
        {
            return
        }
        
        //2. CommandBuffer
        guard let commandBuffer = metalCommandQueue!.makeCommandBuffer()
        else
        {fatalError("MetalView draw(): error, no hay commandBuffer")}
        
        //3. RenderPassDescriptor
        guard let renderPassDescriptor =  view.currentRenderPassDescriptor else
        {fatalError("MetalView draw(): error, no hay renderpassDescriptor")}
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.1, 0.1 , 0.1 , 0.4)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
       
        
        //4. RenderEncoder
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else
        {fatalError("MetalView draw(): error, no hay renderEncoder")}
        
        //Set render state and resources.
        renderEncoder.setRenderPipelineState(pipelineState!)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setBlendColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
        //Argumentos
//        contador += 0.001  //incrementar i
//        if (contador > 3.0){ //max 3
//            contador = 0
//        }
//
        
        let partes: Float = Float(Date.now.timeIntervalSince1970 - initialTime).truncatingRemainder(dividingBy: loopDuration)
        let angulo: Float = Float((360/60 / loopDuration) * Float(Date.now.timeIntervalSince1970 - initialTime)).truncatingRemainder(dividingBy: 360)
        //print("Angulo: \(angulo)")
        var argument = argumentDataColor(rotationAngle1: angulo,rotationAngle2: angulo/2) //angulo de giro
        
        
        renderEncoder.setVertexBytes(&argument, length: MemoryLayout<argumentDataColor>.stride, index: 1)
        
        
        //Draw
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
   
        

        
        // 3.END encoding your onscreen render pass.
        renderEncoder.endEncoding()
        
        // 4. Register the drawable's presentation.
        commandBuffer.present(drawable)
        
        // 5.Finalize your onscreen CPU work and commit the command buffer to a GPU.
        commandBuffer.commit()
    }
    
    //MARK: draw cubo
    //Draw cubo
    @MainActor
    func draw_cubo(in view: MTKView)
    {
        //1. Drawable
        guard let drawable = view.currentDrawable else
        {
            return
        }
        
        //2. CommandBuffer
        guard let commandBuffer = metalCommandQueue!.makeCommandBuffer()
        else
        {fatalError("MetalView draw(): error, no hay commandBuffer")}
        
        //3. RenderPassDescriptor
        guard let renderPassDescriptor =  view.currentRenderPassDescriptor else
        {fatalError("MetalView draw(): error, no hay renderpassDescriptor")}
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.1, 0.1 , 0.1 , 0.4)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
  
        
        //4. RenderEncoder
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else
        {fatalError("MetalView draw(): error, no hay renderEncoder")}
        
        //Set render state and resources.
        renderEncoder.setRenderPipelineState(pipelineState!)
        renderEncoder.setVertexBuffer(vertexBufferCubo, offset: 0, index: 0)
        renderEncoder.setBlendColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)

        
        //let partes: Float = Float(Date.now.timeIntervalSince1970 - initialTime).truncatingRemainder(dividingBy: loopDuration)
        let angulo: Float = Float((360/60 / loopDuration) * Float(Date.now.timeIntervalSince1970 - initialTime)).truncatingRemainder(dividingBy: 360)
        //print("Angulo: \(angulo)")
      
        //Matrix uniforms
        let yAxis = simd_float4(0, -1, 0 , 0)
        let xAxis = simd_float4(1, 0, 0 , 0)
        let zAxis = simd_float4(0, 0, -0.8 , 0)
       
        //Matriz identidad
        var matrix_id = matrix_identity_float4x4
    
        var matrix_model_rot = MatrixFunctions.rotationAboutAxis(zAxis, byAngle: angulo)
        var matrix_model_scale =  MatrixFunctions.makeScaleMatrix(xScale: 0.2, yScale: 0.2)
        
        matrix_model_rot =  matrix_model_rot * matrix_model_scale * matrix_id
        var matrix_perspective = MatrixFunctions.perspectiveProjection(aspect, fieldOfViewY: 60, near: 0.1, far: 100.0)
        
        //makeScaleMatrix(xScale: 0.5, yScale: 0.5)
        

       // var Time = Date.now.timeIntervalSince1970  * 1000
        var currentFrame = uptime()
        var deltaTime = Float(currentFrame - lastFrame)
        var cameraSpeed = Float(0.5) * deltaTime
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
        
        

//
//        if (keyPushed == GLFW_KEY_A)
//            cameraPos -= glm::normalize(glm::cross(cameraFront, cameraUp)) * cameraSpeed;
//
//        if (keyPushed == GLFW_KEY_D)
//            cameraPos += glm::normalize(glm::cross(cameraFront, cameraUp)) * cameraSpeed;

        
        let cameraCenter = cameraPos + cameraFront
        let view = GLKMatrix4MakeLookAt(cameraPos.x, cameraPos.y, cameraPos.z,
                                        cameraCenter.x, cameraCenter.y, cameraCenter.z,
                                        cameraUp.x, cameraUp.y, cameraUp.z)
        
     
        let view_x = simd_float4(view.m00,view.m01,view.m02,view.m03)
        let view_y = simd_float4(view.m10,view.m11,view.m12,view.m13)
        let view_z = simd_float4(view.m20,view.m21,view.m22,view.m23)
        let view_w = simd_float4(view.m30,view.m31,view.m32,view.m33)
//        let view_x = simd_float4(view.m00,view.m10,view.m20,view.m30)
//        let view_y = simd_float4(view.m01,view.m11,view.m21,view.m31)
//        let view_z = simd_float4(view.m02,view.m12,view.m22,view.m32)
//        let view_w = simd_float4(view.m03,view.m13,view.m23,view.m33)

        let view_camera = simd_float4x4(view_x, view_y, view_z, view_w)
        
        
        var argument = ArgumentDataCuboRotacion(rotationAngle1: angulo, projection: matrix_perspective, modelview: view_camera*matrix_model_rot)
        
        renderEncoder.setVertexBytes(&argument, length: MemoryLayout<ArgumentDataCuboRotacion>.stride, index: 1)
        
       // renderEncoder.setVisibilityResultMode(MTLVisibilityResultMode.boolean, offset: 0)
        //Draw
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 36)
   
        
//        var depthDescriptor = MTLDepthStencilDescriptor()
//        depthDescriptor.depthCompareFunction = MTLCompareFunctionLessEqual
//        depthDescriptor.depthWriteEnabled = YES
//
        // 3.END encoding your onscreen render pass.
        renderEncoder.endEncoding()
        
        // 4. Register the drawable's presentation.
        commandBuffer.present(drawable)
        
        // 5.Finalize your onscreen CPU work and commit the command buffer to a GPU.
        commandBuffer.commit()
    }
    
 
    
    
}
    
