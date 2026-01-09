//
//  DetailClusterView.swift
//  qping-5g
//
//  Created by Alejandro Garcia on 2/3/24.
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

import SwiftUI

struct PingNodeView: View {
    @Environment(UIState.self) private var uiState
    
    @State var nodeIP = ""
    @State var QUIC = true
    let step = 100
    let range = 100...1000

    #if os(iOS)
        let espaciado = 0.0
    #endif

    #if os(macOS)
        let espaciado = 5.0
    #endif

    var body: some View {
        VStack {
          
            TabView {
                KPingView()
                    //.badge(2)  // <- globos con el nº :-)
                    .tabItem {
                        Label("ping", systemImage: "network")
                    }
                ChartNodeView()
                    //.badge(2)  // <- globos con el nº :-)
                    .tabItem {
                        Label("graph", systemImage: "chart.xyaxis.line")
                    }
            }
        }
    }
}

#Preview {
    PingNodeView().environment(UIState.shared)
}
