//
//  Mouse.swift
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


import simd

///
/// https://github.com/twohyjr/NSView-Keyboard-and-Mouse-Input
///

enum MouseCodes: Int {
    case left = 0
    case right = 1
    case center = 2
}

@MainActor
struct Mouse {
    
    static let shared = Mouse()
    
    private  static let MOUSE_BUTTON_COUNT = 12
    private  static var mouseButtonList = [Bool].init(repeating: false, count: MOUSE_BUTTON_COUNT)
    
    private  static var overallMousePosition = SIMD2(repeating:Float(0.0))
    private  static var mousePositionDelta = SIMD2(repeating:Float(0.0))
    
    private  static var scrollWheelPosition: Float = 0.0
    private  static var lastWheelPosition: Float = 0.0
    private  static var scrollWheelChange: Float = 0.0
    
    public static  var overrallPosX: Float {
        return overallMousePosition.x
    }
    
    public static  var overrallPosY: Float {
        return overallMousePosition.y
    }
    
    public  static func SetMouseButtonPressed(button: Int, isOn: Bool){
        mouseButtonList[button] = isOn
    }
    
    public static func IsMouseButtonPressed(button: MouseCodes)->Bool{
        return mouseButtonList[Int(button.rawValue)] == true
    }
    
    public  static func SetOverallMousePosition(position: SIMD2<Float>){
        overallMousePosition = position
    }
    
    public static func ResetMouseDelta(){
        self.mousePositionDelta = SIMD2(repeating:Float(0.0))
    }
    
    ///Sets the delta distance the mouse had moved
    public  static func SetMousePositionChange(overallPosition: SIMD2<Float>, deltaPosition: SIMD2<Float>){
        self.overallMousePosition = overallPosition
        self.mousePositionDelta += deltaPosition
    }
    
    public static  func ScrollMouse(deltaY: Float){
        scrollWheelPosition += deltaY
        scrollWheelChange += deltaY
    }
    
    //Returns the overall position of the mouse on the current window
    public static func GetMouseWindowPosition()->SIMD2<Float>{
        return overallMousePosition
    }
    
    ///Returns the movement of the wheel since last time getDWheel() was called
    public static func GetDWheel()->Float{
        let position = scrollWheelChange
        scrollWheelChange = 0
        return position
    }
    
    ///Movement on the y axis since last time getDY() was called.
    public  static func GetDY()->Float{
        let result = mousePositionDelta.y
        mousePositionDelta.y = 0
        return result
    }
    
    ///Movement on the x axis since last time getDX() was called.
    public  static func GetDX()->Float{
        let result = mousePositionDelta.x
        mousePositionDelta.x = 0
        return result
    }
    
    //Returns the mouse position in screen-view coordinates [-1, 1]
    public static  func GetMouseViewportPosition(view: MTKViewCustom)->SIMD2<Float>{
        let x = (overallMousePosition.x - Float(view.bounds.width) * 0.5) / (Float(view.bounds.width) * 0.5)
        let y = (overallMousePosition.y - Float(view.bounds.height) * 0.5) / (Float(view.bounds.height) * 0.5)
        return SIMD2(x, y)
    }
}

