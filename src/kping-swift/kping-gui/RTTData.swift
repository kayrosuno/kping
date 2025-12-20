//
//  RTTData.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 18/2/24.
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
import SwiftUI
import SwiftData

///
///Class RTTData
///Un dato concreto de latencia medido por qping
///
struct RTTData: Hashable, Identifiable
{
    static func == (lhs: RTTData, rhs: RTTData) -> Bool {
        return lhs.timeReceived == rhs.timeReceived
    }
    
    // var timeSend: Double = 0.0
    var timeReceived: Double = 0.0
    var delay: Double = 0.0
    var string: String = ""
    var id:Int64  = 0
    
    init(string: String, id: Int64, timeReceived: Double, delay: Double) {
        self.string = string
        self.id = id
        self.timeReceived = timeReceived
        self.delay = delay
    }
    
    func hash(into hasher: inout Hasher) {
           hasher.combine(timeReceived)
       }
}

