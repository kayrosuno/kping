//
//  Qping.swift
//  qping
//
//  Created by Alejandro on 27/4/25.
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
import Network

/// Enumeracion de tipos de log level
enum QPingLogLevel: Int, Codable {
    case Error = 0
    case Warning
    case Info
    case Debug
    
}

// QPiong struct containing global parameters and variables.
@MainActor
struct QPing {
    
    /// Default port used for qping. 25450. Adapated to kubernetes cluster.
    nonisolated(unsafe) static let log_level:QPingLogLevel = QPingLogLevel.Debug
    /// Default port used for qping. 25450. Adapated to kubernetes cluster.
    static let portDefault = "25450"
    ///Program name
    static let Program = "qping"
    /// Nombre del programa
    //Version
    static let Version = "0.3.2"
    /// Version actual
    /// Longitud en bytes maximo del mensaje
    static let maxMessage = 2024
    /// The UDP maximum package size is 64K 65536
    nonisolated(unsafe) static let MTU = 65536
    /// Max num of lines to show in GUI interface (really are characters)
    static let MAX_LINES_GUI = 150
    /// Default message
    static let mensaje = "qping client mensaje"
    /// Mensaje standar
    static let mensaje_data = "mensaje".data(using: .utf8)
    /// QClient instance
    nonisolated(unsafe) static var qclient: QClient?
    /// QServer instance
    nonisolated(unsafe) static var qserver: QServer?
    /// GUI Data
    nonisolated(unsafe)  static var qpingAppData: QPingAppData?
    /// Estado de nwConnection. //TODO: de client or server???
    static var estado = NWConnection.State.cancelled
    /// Time delayed to wait and send for a query in ms
    static let DELAY_LOOP_SERVER_ns: UInt64 = 1000000000 * 10
    /// Time out de la conexion. 1min
    nonisolated(unsafe) static let CONNECTION_TIMEOUT = 1000 * 60 * 1
    /// 1SEG in nano
    static let DELAY_1SEG_ns: UInt64 = 1000000000
    /// client loop for  conditional exit
    nonisolated(unsafe) static var clientLoop = true
    ///JSON Encoder
//    static let encoder = JSONEncoder()
//    ///JSON Decoder
//    static let decoder = JSONDecoder()
//    /// contador de print
    nonisolated(unsafe) static var print_id:Int64 = 0

    static func setClientLoop(_ value: Bool) async {
        self.clientLoop = value
    }
    
    static func setQClient(_ value: QClient) async {
        self.qclient = value
    }
    
}

