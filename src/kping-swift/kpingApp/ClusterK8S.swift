//
//  ClusterK8S.swift
//  kping-gui
//
//  Created by Alejandro Garcia on 18/2/24.
//
//  Copyright © 2023-2026 Alejandro Garcia <iacobus75@gmail.com>  <alejandro@kayros.uno>
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
@Observable
final class ClusterK8S: @unchecked Sendable, Identifiable, Hashable {

    static func == (lhs: ClusterK8S, rhs: ClusterK8S) -> Bool {
        return lhs.id == rhs.id
    }
    /// id de identificar único.
    let id: UUID
    
    ///Invalid id (cluster not initialice)
    static let idINVALID: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    
    /// Data ClusterK8SData
    let clusterData: ClusterK8SData
    /// String output
    var kpingDataString:[RTTData] = [
       // RTTData(string: "", /*id: 0,*/ timeReceived: uptime(), delay: 0.0, rtt: 0.0)
    ]
    /// qpingData, array de RTTData para chart
    var kpingDataChart:[RTTData] = [
       // RTTData(string: "", /*id: 0, */timeReceived: uptime(), delay: 0.0, rtt: 0.0)
    ]
    /// Tiempo inicial
    //var startTime = uptime()
    /// Protocolo a utilizar en la conexion
    var kpingProtocol: String = "UDP+QUIC"
    ///Cluster state, refer to statoe
    var estadoCluster = "Stop"
    //Send interval between pings in ns
    var sendIntervalns = 1000 * 1000 * 1000//ns, default 1000ms=1seg
    /// Delay between send request
    //var delayns = 0.0  //ms
    //Para visualizar, datos en clusterk8s, el view debe de estar asociado a un objeto observble.
    /// Min RTT del cluster
    var minRTTns = 0.0
    ///medRTT
    var medRTTns = 0.0
    /// Max RTT del cluster
    var maxRTTns = 0.0
    /// Last RTT del cluster
    var actualRTTns = 0.0
    ///Counter
    private(set) var idCounter: Int64 = 0
    /// QCLient
    var qclient: QClient?
    
    /// init ClusterK8S
    init(clusterData: ClusterK8SData)  //Utilizar el mismo id del cluster que el modelo de datos ClusterK8SData
    {
        self.clusterData = clusterData
        self.id = clusterData.id
       // self.appData = appData
    }

    //dummy initialzer
    init()
    {
        self.clusterData = ClusterK8SData(id: ClusterK8S.idINVALID, name: "dummy", port: 0, nodes: [])
        self.id = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

//    func setClusterData(clusterData: ClusterK8SData) {
//        self.clusterData = clusterData
//        self.id = clusterData.id
//    }
    
    /// Resetear contadores
    func resetCounter() {
        kpingDataChart.removeAll(keepingCapacity: true)
        kpingDataString.removeAll(keepingCapacity: true)
        //startTime = 0
    }
    
    func getCounterAndInc() -> Int64 {
        let counter = idCounter
        idCounter = idCounter + 1
        
        return counter
    }
}
