//
//  AppData.swift
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
import Combine
import SwiftData

///
///Datos de la aplicación GUI, observable.
///
class KPingAppData: Identifiable, ObservableObject {
   
    @Published var showAboutView = false
    
    /// Ejecutar qping. Enlazado a los botones stop y start en DetailClusterView
    @Published var runPing = false
    @Published var path: NavigationPath
    @Published var vistaActiva = TipoVistaActiva.root
    
    /// Cluster seleccionado en la pantalla lateral
    @Published var selectedCluster: ClusterK8SData?
    
    /// Cluster que se está editando
    @Published var editCluster: ClusterK8SData?
    
    /// Cluster que esta ejecutándose (running)
    @Published var clusterRunning: ClusterK8S?
    @Published var QUIC_UDP = true
    //var estadoCluster = "Stop"
    //var qpingOutputNode = ""
    @Published var sendIntervalns = 1000.0 * 1000 * 1000//ns, default 1000ms=1seg
    @Published var sidebarbackground: (any View)?
    @Published var selectionProtocol = "QUIC+UDP"
   // var nodeSelected = ""
    
    //Para visualizar, datos en clusterk8s, el view debe de estar asociado a un objeto observble.
    /// Min RTT del cluster
    @Published var minRTTns = 0.0
    ///medRTT
    @Published var medRTTns = 0.0
    /// Max RTT del cluster
    @Published var maxRTTns = 0.0
    /// Last RTT del cluster
    @Published var actualRTTns = 0.0
    
    /// Time de actualizacon datos del GUI
    @Published var timestamp: String = TimeNow()
    
    init(path: NavigationPath){
        self.path = path
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

