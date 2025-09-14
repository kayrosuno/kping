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

struct DetailClusterView: View {

    @EnvironmentObject var qpingAppData: QPingAppData

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
            HStack {
                Gauge(
                    value: Double(
                        (qpingAppData.actualRTTns / 1000).fractionDigitsRounded(
                            to: 1
                        )
                    ) ?? 0.0,
                    in: 0.0...(qpingAppData.maxRTTns / 1000) + 1
                ) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                } currentValueLabel: {
                    Text(
                        "\((qpingAppData.actualRTTns/1000).fractionDigitsRounded(to: 1))"
                    )
                    .foregroundColor(Color.green)
                } minimumValueLabel: {
                    Text(
                        "\((qpingAppData.minRTTns/1000).fractionDigitsRounded(to: 0))"
                    )
                    .foregroundColor(Color.blue)
                } maximumValueLabel: {
                    Text(
                        "\((qpingAppData.maxRTTns/1000).fractionDigitsRounded(to: 0))"
                    )
                    .foregroundColor(Color.red)
                }
                .frame(alignment: .center)
                .gaugeStyle(.accessoryCircular)  //.frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(
                    EdgeInsets(
                        top: 5.0,
                        leading: espaciado + 15.0,
                        bottom: 5.0,
                        trailing: 5.0
                    )
                ).foregroundColor(.blue)

                Spacer()
                Text(
                    "min RTT: \((qpingAppData.minRTTns/1000).fractionDigitsRounded(to: 1)) ms"
                ).multilineTextAlignment(.leading).padding(
                    EdgeInsets(
                        top: 5.0,
                        leading: 5.0,
                        bottom: 5.0,
                        trailing: 5.0
                    )
                ).foregroundColor(.blue)
                Spacer()
                Text(
                    "med RTT: \((qpingAppData.medRTTns/1000).fractionDigitsRounded(to: 1)) ms"
                ).multilineTextAlignment(.leading).padding(
                    EdgeInsets(
                        top: 5.0,
                        leading: 5.0,
                        bottom: 5.0,
                        trailing: 5.0
                    )
                ).foregroundColor(.green)
                Spacer()
                Text(
                    "max RTT: \((qpingAppData.maxRTTns/1000).fractionDigitsRounded(to: 1)) ms"
                ).multilineTextAlignment(.leading).padding(
                    EdgeInsets(
                        top: 5.0,
                        leading: 5.0,
                        bottom: 5.0,
                        trailing: 5.0
                    )
                ).foregroundColor(.red)
                Spacer()
            }
            TabView {
                QPingView()
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

//#Preview {
//    DetailClusterView()
//}
