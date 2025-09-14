//
//  ClusterK8S.swift
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
import Network
import SwiftData
import SwiftUI

///
/// Clase ClusterK8
///
//@Observable
class ClusterK8S: Identifiable, Hashable {

    static func == (lhs: ClusterK8S, rhs: ClusterK8S) -> Bool {
        return lhs.id == rhs.id
    }
    /// id de identificar único
    let id: UUID
    /// Data ClusterK8SData
    let clusterData: ClusterK8SData
    /// String output
    var qpingDataString = [
        RTTData(string: "", id: 0, timeReceived: uptime(), delay: 0.0)
    ]
    /// qpingData, array de RTTData para chart
    var qpingDataChart = [
        RTTData(string: "", id: 0, timeReceived: uptime(), delay: 0.0)
    ]
    /// Tiempo inicial
    var startTime = uptime()
    
    ///Cluster state, refer to statoe
    var estadoCluster = "Stop"
    /// Delay between send request
    //var delayns = 0.0  //ms
    ///AppData, reference to update swiftUI
    private var appData: QPingAppData?

    /// init ClusterK8S
    init(clusterData: ClusterK8SData, appData: QPingAppData)  //Utilizar el mismo id del cluster que el modelo de datos ClusterK8SData
    {
        self.clusterData = clusterData
        self.id = clusterData.id
        self.appData = appData
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// Resetear contadores
    func resetCounter() {
        qpingDataChart.removeAll(keepingCapacity: true)
        qpingDataString.removeAll(keepingCapacity: true)
        startTime = 0
    }
}
