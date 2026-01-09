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
                                    (uiState.actualRTTns / 1000).fractionDigitsRounded(
                                        to: 1
                                    )
                                ) ?? 0.0,
                                in: 0.0...(uiState.maxRTTns / 1000) + 1
                            ) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                            } currentValueLabel: {
                                Text(
                                    "\((uiState.actualRTTns/1000).fractionDigitsRounded(to: 1))"
                                )
                                .foregroundColor(Color.green)
                            } minimumValueLabel: {
                                Text(
                                    "\((uiState.minRTTns/1000).fractionDigitsRounded(to: 0))"
                                )
                                .foregroundColor(Color.blue)
                            } maximumValueLabel: {
                                Text(
                                    "\((uiState.maxRTTns/1000).fractionDigitsRounded(to: 0))"
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
                                "min RTT: \((uiState.minRTTns/1000).fractionDigitsRounded(to: 1)) ms"
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
                                "med RTT: \((uiState.medRTTns/1000).fractionDigitsRounded(to: 1)) ms"
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
                                "max RTT: \((uiState.maxRTTns/1000).fractionDigitsRounded(to: 1)) ms"
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
                                HStack {
                                    Text("\(uiState.timestamp)")
                                    Spacer()
#if os(iOS)
                                    Button(
                                        action: {  //Trash
                                            if uiState.clusterRunning.id != ClusterK8S.idINVALID {
                                                uiState.clusterRunning.resetCounter()
                                            }
                                            uiState.actualRTTns = 0.0  // Para resfrescar los datos.
                                        },
                                        label: {
                                            HStack {
                                                Text("Clear")
                                                Image(systemName: "trash")
                                            }
                                        }
                                    )
                                    
                                    .frame(maxWidth: 93, alignment: .trailing)
                                    .padding(
                                        EdgeInsets(
                                            top: 5.0,
                                            leading: 0.0,
                                            bottom: 5.0,
                                            trailing: 0
                                        )
                                    )
#endif
                                } .padding(
                                    EdgeInsets(
                                        top: 0.0,
                                        leading: 5.0,
                                        bottom: 0.0,
                                        trailing: 5.0
                                    )
                                )
                                
                                ScrollView {
                                    //HStack{
                                    ForEach(uiState.clusterRunning.kpingDataString) { item in
                                        HStack {
                                            Text(item.string).multilineTextAlignment(
                                                .leading
                                            )
                                            Spacer()
                                        }
                                        .padding(
                                            EdgeInsets(
                                                top: 0.0,
                                                leading: 5.0,
                                                bottom: 0.0,
                                                trailing: 5.0
                                            )
                                        )
                                        .frame(maxWidth: .infinity)
                                    }
                                }.defaultScrollAnchor(.bottom)
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
                        HStack {
                            Text("").padding(
                                EdgeInsets(
                                    top: 5.0,
                                    leading: 5.0,
                                    bottom: 5.0,
                                    trailing: 5.0
                                )
                            )
                            Spacer()
                        }}
                }
            }
            else {
                Text("")
            }
        }
    }
}

//#Preview {
//    KPingView().environment(UIState.shared)
//}
