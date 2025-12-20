//
//  ClusterK8SData.swift
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
/// Modelo de datos para swiftdata con la inforamción de los Clusters/nodes
///
@Model
class ClusterK8SData: Identifiable, Hashable{
    @Attribute(.unique) var id: UUID
    var name: String
    var port: UInt16 = 25450 //Default port
    var nodes: [String]
    var nodeSelected = 0 //Default. 1st node
   
    init(id: UUID, name: String, port: UInt16, nodes: [String]) {
        self.id = id
        self.name = name
        self.port = port
        self.nodes = nodes
    }
}
