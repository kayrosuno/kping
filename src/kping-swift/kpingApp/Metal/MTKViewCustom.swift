//
//  MtlViewCustom.swift
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
import MetalKit


class MTKViewCustom: MTKView
{
//    var view: UIView
//    
//    init(view: UIView)
//    {
//        self.view = view
//        super.init(
//    }
    
    var deltaX = 0.0
    var deltaY = 0.0
    var lastX = 0.0
    var lastY = 0.0
   
}


#if canImport(AppKit)
//--- Keyboard Input ---
extension MTKViewCustom { // <<<< -----------------Replace GameView with the view name you want keyboard input on
    override var acceptsFirstResponder: Bool { return true }
    
    
    override func keyDown(with event: NSEvent) {
        Keyboard.SetKeyPressed(event.keyCode, isOn: true)
       // print("Keydown")
        
        self.setNeedsDisplay(self.bounds)
    }
    
    override func keyUp(with event: NSEvent) {
        Keyboard.SetKeyPressed(event.keyCode, isOn: false)
       // print("Keyup")
        self.setNeedsDisplay(self.bounds)
    }
}



//--- Mouse Button Input ---
extension MTKViewCustom {  // <<<< -----------------Replace GameView with the view name you want keyboard input on
    override func mouseDown(with event: NSEvent) {
        Mouse.SetMouseButtonPressed(button: event.buttonNumber, isOn: true)
        Mouse.ResetMouseDelta()
        //self.setNeedsDisplay(self.bounds)
    }
    
    override func mouseUp(with event: NSEvent) {
        Mouse.SetMouseButtonPressed(button: event.buttonNumber, isOn: false)
    }
    
    override func rightMouseDown(with event: NSEvent) {
        Mouse.SetMouseButtonPressed(button: event.buttonNumber, isOn: true)
        Mouse.ResetMouseDelta()
    }
    
    override func rightMouseUp(with event: NSEvent) {
        Mouse.SetMouseButtonPressed(button: event.buttonNumber, isOn: false)
    }
    
    override func otherMouseDown(with event: NSEvent) {
        Mouse.SetMouseButtonPressed(button: event.buttonNumber, isOn: true)
        Mouse.ResetMouseDelta()
    }
    
    override func otherMouseUp(with event: NSEvent) {
        Mouse.SetMouseButtonPressed(button: event.buttonNumber, isOn: false)
    }
    
}

// --- Mouse Movement ---
extension MTKViewCustom {  // <<<< -----------------Replace GameView with the view name you want keyboard input on
    override func mouseMoved(with event: NSEvent) {
        setMousePositionChanged(event: event)
    }
    
    override func scrollWheel(with event: NSEvent) {
        Mouse.ScrollMouse(deltaY: Float(event.deltaY))
        self.setNeedsDisplay(self.bounds)
    }
    
    override func mouseDragged(with event: NSEvent) {
        setMousePositionChanged(event: event)
       
    }
    
    override func rightMouseDragged(with event: NSEvent) {
        setMousePositionChanged(event: event)
    }
    
    override func otherMouseDragged(with event: NSEvent) {
        setMousePositionChanged(event: event)
        
    }
    
    private func setMousePositionChanged(event: NSEvent){
        let overallLocation = SIMD2(Float(event.locationInWindow.x),
                                     Float(event.locationInWindow.y))
        let deltaChange = SIMD2(Float(event.deltaX),
                                 Float(event.deltaY))
        Mouse.SetMousePositionChange(overallPosition: overallLocation,
                                     deltaPosition: deltaChange)
        
        //print("Mouse overall:\(overallLocation)")
        //print("Mouse overall:\(deltaChange)")
        self.setNeedsDisplay(self.bounds)
    }
    
    override func updateTrackingAreas() {
        let area = NSTrackingArea(rect: self.bounds,
                                  options: [NSTrackingArea.Options.activeAlways,
                                            NSTrackingArea.Options.mouseMoved,
                                            NSTrackingArea.Options.enabledDuringMouseDrag],
                                  owner: self,
                                  userInfo: nil)
        self.addTrackingArea(area)
    }
    
}
#endif




#if canImport(UIKit)
//--- Keyboard Input ---
extension MTKViewCustom { // <<<< -----------------Replace GameView with the view name you want keyboard input on
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {  //Coge solo la primera posicion de los touches para mover, sino se hace un lio
            let position = touch.location(in: self)
            //print("Began: \(position)")
            lastX = position.x
            lastY = position.y
        }
        
        Mouse.SetMouseButtonPressed(button: 0, isOn: true)
        Mouse.ResetMouseDelta()
        deltaX = 0.0
        deltaY = 0.0
        if touches.count < 2
        {
            Keyboard.SetKeyPressed(UInt16(0x0D), isOn: true)
        }
        else
        {
            Keyboard.SetKeyPressed(UInt16(0x01), isOn: true)
        }
    }

    override func touchesMoved(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        if let touch = touches.first {
            let position = touch.location(in: self)
            //print("moved \(position)")
            setMousePositionChanged(location: position)
            
            //Calcular Delta
            deltaX = position.x - lastX
            deltaY = position.y - lastY
            lastX = position.x
            lastY = position.y
            
            
        }
        
    }
    
    
    override func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ){
        if let touch = touches.first {
            let position = touch.location(in: self)
            //print("End \(position)")
            //TODO
        }
        
        Mouse.SetMouseButtonPressed(button: 0 /*left*/, isOn: false)
        Keyboard.SetKeyPressed(UInt16(0x0D), isOn: false)
        Keyboard.SetKeyPressed(UInt16(0x01), isOn: false)

    }
    
    
    override func touchesCancelled(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    )
    {
        Mouse.SetMouseButtonPressed(button: 0 /*left*/, isOn: false)
     
            Keyboard.SetKeyPressed(UInt16(0x0D), isOn: false)
            Keyboard.SetKeyPressed(UInt16(0x01), isOn: false)
   
       
    }
    private func setMousePositionChanged(location: CGPoint){
        let overallLocation = SIMD2(Float(location.x),
                                     Float(location.y))
        let deltaChange = SIMD2(Float(deltaX),
                                 Float(deltaY))
        Mouse.SetMousePositionChange(overallPosition: overallLocation,
                                     deltaPosition: deltaChange)
        
        //print("Mouse overall:\(overallLocation)")
        //print("Mouse delta:\(deltaChange)")
    }
    
}
#endif
