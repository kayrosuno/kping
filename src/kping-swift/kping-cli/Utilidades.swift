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
nonisolated func uptime()  -> Double
{
    return ProcessInfo.processInfo.systemUptime
}

/// Devuelve el time en HH:mm:ss. Utilizar para formatear tiempo para logs.
nonisolated func TimeNow() -> String
{
    // 1. Choose a date
    let today = Date()
    
    let df = DateFormatter()
   // df.dateFormat = "y-MM-dd H:mm:ss.SSSS"
    df.dateFormat = "H:mm:ss.SSSS"
    
    return df.string(from: today)
}
///Time in us
nonisolated func TimeNowDouble() -> Double
{
    return Date().timeIntervalSince1970 * 1000 * 1000
}

// Versión con formato personalizado
nonisolated func formatUptime(_ microseconds: Double) -> String {
    let seconds = microseconds / 1_000_000.0
    let date = Date(timeIntervalSince1970: seconds)
    
    
    // Formatear la fecha
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    formatter.locale = Locale(identifier: "es_ES")
    
//    return formatter.string(from: date)
//    let formatter = DateFormatter()
//    formatter.dateFormat = format
//    formatter.locale = Locale(identifier: "es_ES")
    
    return formatter.string(from: date)
}



//nonisolated func formatUptime(uptime: Double) -> String
//{
//    
//    // Calcular la fecha de inicio del sistema
//    let bootDate = Date(timeIntervalSinceNow: -uptime)
//    
//    Date(
//
//    // Formatear la fecha
//    let formatter = DateFormatter()
//    formatter.dateStyle = .medium
//    formatter.timeStyle = .medium
//    formatter.locale = Locale(identifier: "es_ES")
//
//    
//    formatter.string(from: bootDate)
//    
//    //print("Tiempo de actividad: \(uptime) segundos")
//    //print("El sistema se inició el: \(formatter.string(from: bootDate))")
//
//    // Alternativamente, puedes formatear el uptime como duración
//    func formatUptime(_ seconds: TimeInterval) -> String {
//        let days = Int(seconds) / 86400
//        let hours = (Int(seconds) % 86400) / 3600
//        let minutes = (Int(seconds) % 3600) / 60
//        let secs = Int(seconds) % 60
//        
//        return String(format: "%d días, %02d:%02d:%02d", days, hours, minutes, secs)
//    }
//
//    
//}

///GENERAL:  print DEBUG if log level is set in QPing to QPingLogLevel.Debug
nonisolated func printDEBUG(_ cadena: String) {
    if KPingState.log_level == KPingLogLevel.Debug {
        print(cadena)
    }
}
