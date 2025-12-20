//
//  Utilidades.swift
//  qs1
//
//  Created by Alejandro Garcia on 12/6/23.
//
//  Copyright © 2023-2025 Alejandro Garcia <iacobus75@gmail.com>  <alejandro@kayros.uno>
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
import Network

/// Devuelve un time en uSec, el tiempo del sistema en uSec. Utilizar para comparar tiempo en usec.
/// El time es la cantidad de tiempo que el sistema esta awake.
/// https://developer.apple.com/forums/thread/101874
/// https://forums.swift.org/t/recommended-way-to-measure-time-in-swift/33326
func uptime()  -> Double
{
    return ProcessInfo.processInfo.systemUptime
}

/// Devuelve el time en HH:mm:ss. Utilizar para formatear tiempo para logs.
func TimeNow() -> String
{
    
    // 1. Choose a date
    let today = Date()
    
    let df = DateFormatter()
   // df.dateFormat = "y-MM-dd H:mm:ss.SSSS"
    df.dateFormat = "H:mm:ss.SSSS"
    
   
    return df.string(from: today)
}

///GENERAL:  print DEBUG if log level is set in QPing to QPingLogLevel.Debug
@Sendable func printDEBUG(_ cadena: String) {
   
    if QPing.log_level == QPingLogLevel.Debug {
        print(cadena)
    }
}
