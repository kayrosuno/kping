//
//  AppData.swift
//  kping-gui
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
import Combine
import SwiftData

///
///Datos de la aplicación GUI, observable.
///
@Observable
@MainActor
class UIState{
    //Singleton
    static let shared = UIState()
   
    var showAboutView = false
    
    /// Ejecutar qping. Enlazado a los botones stop y start en NodeView
    var runPing = false
    var path = NavigationPath()
    var vistaActiva = TipoVistaActiva.root
    
    /// Cluster seleccionado en sidebarview. Listado de clusterData.
    var UUIDSelectedCluster: UUID? = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    
    /// Cluster que se está editando
    var editCluster = ClusterK8S()
    
    /// Cluster que esta ejecutándose (running)
    var clusterRunning = ClusterK8S()
    
    var QUIC_UDP = true
    //var estadoCluster = "Stop"
    //var qpingOutputNode = ""
   
    var sidebarbackground: (any View)?
    // var selectionProtocol = "QUIC+UDP"
    // var nodeSelected = ""
       
    /// Time de actualizacon datos del GUI
    var timestamp: String = TimeNow()
    
    /// Send interval between pings in ns
    //var sendIntervalns = 1000 * 1000 * 1000//ns, default 1000ms=1seg
    
    /// qclient
    //var qclient: QClient?
    
    private init() {}
    
    func setTimeStamp(timestamp: String) {
        self.timestamp = timestamp
    }
}

extension Formatter {
    static let number = NumberFormatter()
}

extension FloatingPoint {
    func fractionDigitsRounded(to digits: Int, roundingMode:  NumberFormatter.RoundingMode = .halfEven) -> String {
        Formatter.number.roundingMode = roundingMode
        Formatter.number.minimumFractionDigits = digits
        Formatter.number.maximumFractionDigits = digits
        return Formatter.number.string(for:  self) ?? ""
    }
}

