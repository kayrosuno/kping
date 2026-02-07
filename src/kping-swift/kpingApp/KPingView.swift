//
//  QPingView.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 5/2/24.
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

import CoreTelephony
import Network
import SwiftUI

struct KPingView: View {
    @Environment(UIState.self) private var uiState
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isCompact: Bool { horizontalSizeClass == .compact }
    #else
    private let isCompact = false
    #endif

    //@Environment(ClusterK8S.self) private var clusterRunning
    
    #if os(iOS)
        let espaciado = 0.0
    #endif

    #if os(macOS)
        let espaciado = 5.0
    #endif

    var body: some View {
        if uiState.UUIDSelectedCluster != ClusterK8S.idINVALID {
            if uiState.clusterRunning.id != ClusterK8S.idINVALID {
                if uiState.clusterRunning.id ==  uiState.UUIDSelectedCluster {
                    VStack {
                        HStack {
                            Gauge(
                                value: Double(
                                    (uiState.clusterRunning.actualRTTns / 1000).fractionDigitsRounded(
                                        to: 1
                                    )
                                ) ?? 0.0,
                                in: 0.0...(uiState.clusterRunning.maxRTTns / 1000) + 1
                            ) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                            } currentValueLabel: {
                                Text(
                                    "\((uiState.clusterRunning.actualRTTns/1000).fractionDigitsRounded(to: 1))"
                                )
                                .foregroundColor(Color.green)
                            } minimumValueLabel: {
                                Text(
                                    "\((uiState.clusterRunning.minRTTns/1000).fractionDigitsRounded(to: 0))"
                                )
                                .foregroundColor(Color.blue)
                            } maximumValueLabel: {
                                Text(
                                    "\((uiState.clusterRunning.maxRTTns/1000).fractionDigitsRounded(to: 0))"
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
                                "min RTT: \((uiState.clusterRunning.minRTTns/1000).fractionDigitsRounded(to: 1)) ms"
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
                                "med RTT: \((uiState.clusterRunning.medRTTns/1000).fractionDigitsRounded(to: 1)) ms"
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
                                "max RTT: \((uiState.clusterRunning.maxRTTns/1000).fractionDigitsRounded(to: 1)) ms"
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
                        if uiState.clusterRunning.id != ClusterK8S.idINVALID {
                            VStack {
#if os(iOS)
                                Divider()
                                    .overlay(Color.gray)
#endif
                                HStack(spacing: 0){
#if os(iOS)
                                    Spacer()
                                    Button(
                                        action: {  //Trash
                                            if uiState.clusterRunning.id != ClusterK8S.idINVALID {
                                                uiState.clusterRunning.resetCounter()
                                            }
                                            uiState.clusterRunning.actualRTTns = 0.0  // Para resfrescar los datos.
                                        },
                                        label: {
                                            HStack {
                                                Text("Clear")
                                                Image(systemName: "trash")
                                            }
                                        }
                                    )
                                    .frame(maxWidth: 93, alignment: .leading)
                                   
//                                    .padding(
//                                        EdgeInsets(
//                                            top: 5.0,
//                                            leading: 0.0,
//                                            bottom: 5.0,
//                                            trailing: 0
//                                        )
//                                    )
#endif
                                }
                                #if os(macOS)
                                .padding(
                                    EdgeInsets(
                                        top: 0.0,
                                        leading: 5.0,
                                        bottom: 0.0,
                                        trailing: 5.0
                                    )
                                )
                                #endif
                                
                                    HStack {
#if os(iOS)
                                        Table(uiState.clusterRunning.kpingDataString)
                                        {
                                            TableColumn("id"){
                                                if isCompact {
                                                    Text("\($0.string)")
                                                }
                                                else
                                                {
                                                    Text("\($0.id)")
                                                }
                                            }
                                            TableColumn("TimeReceived"){Text(formatUptime($0.timeReceived))}
                                            TableColumn("Delay"){Text("\(String(format: "%.2f", ($0.delay/1000))) ms")}
                                            TableColumn("RTT"){Text("\(String(format: "%.2f", ($0.rtt/1000))) ms")}
                                            TableColumn("String", value: \.string)
                                        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                            .padding(
                                                EdgeInsets(
                                                    top: 0.0,
                                                    leading: 0.0,
                                                    bottom: 0.0,
                                                    trailing: 0
                                                )
                                            )
                                        Spacer()
                                        
//                                        ScrollView {
//                                            LazyVStack(alignment: .leading) {
//                                                ForEach(uiState.clusterRunning.kpingDataString, id: \.self) {
//                                                    Text("\($0.id)+\($0.timeReceived)+\($0.delay)+\($0.rtt)")
//                                                }
//                                            }
//                                        }

#else
                                        Table(uiState.clusterRunning.kpingDataString)
                                        {
                                            TableColumn("id"){Text("\($0.id)")}.width(min: 10, ideal: 30, max:50)
                                            TableColumn("TimeReceived"){Text(formatUptime($0.timeReceived))}.width(min: 70, ideal: 100, max:150)
                                            TableColumn("Delay"){Text("\(String(format: "%.2f", ($0.delay/1000))) ms")}.width(min: 30, ideal: 50, max:120)
                                            TableColumn("RTT"){Text("\(String(format: "%.2f", ($0.rtt/1000))) ms")}.width(min: 30, ideal: 50, max:120)
                                            TableColumn("String", value: \.string).width(min: 120, ideal: 200, max:1200)
                                        }
#endif
                                    }  .frame(alignment: .leading)
                                    .padding(
                                        EdgeInsets(
                                            top: 0.0,
                                            leading: 0.0,
                                            bottom: 0.0,
                                            trailing: 0
                                        )
                                    )
                            }
                        } else {
                            VStack {
                                HStack {
                                    Text("Estado: Stop").multilineTextAlignment(.leading)
                                        .padding(
                                            EdgeInsets(
                                                top: 5.0,
                                                leading: 5.0,
                                                bottom: 5.0,
                                                trailing: 5.0
                                            )
                                        )
                                    TablaDummy()
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                    }
                }
                else {
                    VStack {
#if os(iOS)
                        Divider()
                            .overlay(Color.gray)
#endif
                        TablaDummy()
                    }
                }
            }
            else {
                Text("State: STOP")
            }
        }
        else{
            Text("State: STOP")
        }
    }
}


struct TablaDummy: View {
#if os(iOS)
@Environment(\.horizontalSizeClass) private var horizontalSizeClass
private var isCompact: Bool { horizontalSizeClass == .compact }
#else
private let isCompact = false
#endif
    let datos = [RTTData(string: "",/*id: 1,*/timeReceived: 0.0, delay: 0.0, rtt:0.0)]
    
    var body: some View {
#if os(iOS)
        Table(datos)
        {
            TableColumn("id"){
                if isCompact {
                    Text("\(formatUptime($0.timeReceived)) \(String(format: "%.2f", ($0.delay/1000)))ms \(String(format: "%.2f", ($0.rtt/1000)))ms \($0.string)")
                }
                else
                {
                    Text("\($0.id)")
                }
            }
            TableColumn("TimeReceived"){Text(formatUptime($0.timeReceived))}
            TableColumn("Delay"){Text("\(String(format: "%.2f", ($0.delay/1000))) ms")}
            TableColumn("RTT"){Text("\(String(format: "%.2f", ($0.rtt/1000))) ms")}
            TableColumn("String", value: \.string)
        }
#else
        Table(datos)
        {
            TableColumn("id"){Text("\($0.id)")}.width(min: 10, ideal: 30, max:50)
            TableColumn("TimeReceived"){Text("\($0.timeReceived)")}.width(min: 30, ideal: 50, max:70)
            TableColumn("Delay"){Text("\($0.delay)")}.width(min: 30, ideal: 50, max:70)
            TableColumn("RTT"){Text("\($0.delay)")}.width(min: 30, ideal: 50, max:70)
            TableColumn("String", value: \.string).width(min: 120, ideal: 200, max:1200)
        }
#endif
    }
}


//#Preview {
//    KPingView().environment(UIState.shared)
//}
