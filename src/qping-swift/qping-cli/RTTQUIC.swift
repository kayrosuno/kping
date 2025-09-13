//
//  RTTQUIC.swift
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


/// Struct for RTT QUIC. Estructura de mensaje de comunicacion entre cliente y servidor.
struct RTTQUIC: Codable  {
    /// id del mensaje
    var Id:                Int64 = 0
    
    /// local time at client microseconds
    var Time_client:       Int = 0
    
    /// local time at server microseconds
    var Time_server:       Int = 0
    
    /// len payload data
    var LenPayload:        Int = 0
    
    /// len data readed on server side for payload (for MTU discovery?)
    var LenPayloadReaded:  Int = 0
    
    /// data of payload
    var Data:              Data?
}
