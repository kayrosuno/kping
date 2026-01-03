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
enum KPingLogLevel: Int, Codable {
    case Error = 0
    case Warning
    case Info
    case Debug
    
}

// KPing struct containing global parameters and variables.

actor KPingState {
    
    /// Default port used for qping. 25450. Adapated to kubernetes cluster.
    static let log_level:KPingLogLevel = KPingLogLevel.Debug
    /// Default port used for qping. 25450. Adapated to kubernetes cluster.
    static let portDefault = "25450"
    ///Program name
    static let Program = "kping"
    /// Nombre del programa
    //Version
    static let Version = "0.3.3"
    /// Version actual
    /// Longitud en bytes maximo del mensaje
    static let maxMessage = 2024
    /// The UDP maximum package size is 64K 65536
    static let MTU = 65536
    /// Max num of lines to show in GUI interface (really are characters)
    static let MAX_LINES_GUI = 150
    /// Default message
    static let mensaje = "kping client message"
    /// Mensaje standar
    static let mensaje_data = "mensaje".data(using: .utf8)
    /// Time delayed to wait and send for a query in ms
    static let DELAY_LOOP_SERVER_ns: UInt64 = 1000000000 * 10
    /// Time out de la conexion. 1min
    static let CONNECTION_TIMEOUT = 1000 * 60 * 1
    /// 1SEG in nano
    static let DELAY_1SEG_ns: UInt64 = 1000000000
    /// QClient instance
    private(set) var qclient: QClient?
    /// QServer instance
    private(set) var qserver: QServer?
    /// GUI Data
    private(set) var qpingAppData: KPingAppData?
    /// Estado de nwConnection. //TODO: de client or server???
    private(set) var estado = NWConnection.State.cancelled
  
    /// client loop for  conditional exit
    private(set)var clientLoop = true
    ///JSON Encoder
//    static let encoder = JSONEncoder()
//    ///JSON Decoder
//    static let decoder = JSONDecoder()
//    /// contador de print
    private(set) var print_id:Int64 = 0

//    func createQClient(host: String, port: UInt16)async -> QClient{
//        self.qclient = QClient(host: host, port: port)
//        return self.qclient!
//    }
    
   
    
    func incPrintId() {
        self.print_id += 1
    }
    
    func setQClient(qclient: QClient)  {
        self.qclient = qclient
    }
    
    func setQServer(qserver: QServer)  {
        self.qserver = qserver
    }
    
    func setClientLoop(_ value: Bool)  {
        self.clientLoop = value
    }
    
    func setQClient(_ value: QClient) {
        self.qclient = value
    }
    
    func setQServer(_ value: QServer){
        self.qserver = value
    }

//    init(qserver: QServer)
//    {
//        self.qserver = qserver
//    }
//    
//    init(qclient: QClient)
//    {
//        self.qclient = qclient
//    }
}

