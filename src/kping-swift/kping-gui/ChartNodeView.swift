//
//  View1.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 31/1/24.
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

import Charts
import SwiftUI

struct ChartNodeView: View {

    @EnvironmentObject var qpingAppData: QPingAppData

    #if os(iOS)
        let espaciado = 0.0
    #endif

    #if os(macOS)
        let espaciado = 5.0
    #endif

    var body: some View {

        if let selectedCluster = qpingAppData.selectedCluster {
            if let clusterRunning = qpingAppData.clusterRunning {
                if clusterRunning.id == selectedCluster.id {
                    VStack {
                        #if os(iOS)
                            Divider()
                                .overlay(Color.gray)
                        #endif
                        HStack {
                            Text(
                                "RTT: \((qpingAppData.actualRTTns/1000).fractionDigitsRounded(to: 2)) ms"
                            )
                            Spacer()
                            #if os(iOS)
                                Button(
                                    action: {  //Trash
                                        if let cluster = qpingAppData
                                            .clusterRunning
                                        {

                                            cluster.resetCounter()
                                        }
                                        qpingAppData.actualRTTns = 0.0  // Para resfrescar los datos.
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
                                        top: 7.0,
                                        leading: 0.0,
                                        bottom: 5.0,
                                        trailing: 0
                                    )
                                )
                            #endif
                        }
                        Chart {
                            ForEach(
                                clusterRunning.qpingDataChart,
                                id: \.timeReceived
                            ) { item in
                                LineMark(
                                    x: .value("Date", item.id),
                                    y: .value("Delay", item.delay / 1000)///1000).fractionDigitsRounded(to: 1))
                                    //   series: .value("Node","A")
                                )
                                .foregroundStyle(.green)
                            }
                            RuleMark(  //Media
                                y: .value(
                                    "med RTT",
                                    qpingAppData.medRTTns / 1000
                                )
                            )
                            .annotation(
                                position: .bottom,
                                alignment: .bottomLeading
                            ) {
                                Text(
                                    "med RTT \((qpingAppData.medRTTns/1000).fractionDigitsRounded(to: 1)) ms"
                                ).font(.system(size: 12))
                            }
                        }
                    }
                } else {
                    VStack {
                        #if os(iOS)
                            Divider()
                                .overlay(Color.gray)
                        #endif
                        HStack {
                            Text("RTT: 0us").padding(
                                EdgeInsets(
                                    top: 5.0,
                                    leading: 5.0,
                                    bottom: 5.0,
                                    trailing: 5.0
                                )
                            )
                            Spacer()

                            #if os(iOS)
                                Button(
                                    action: {  //Trash
                                        if let cluster = qpingAppData
                                            .clusterRunning
                                        {
                                            cluster.resetCounter()
                                        }
                                        qpingAppData.actualRTTns = 0.0  // Para resfrescar los datos.
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
                        }
                    }
                }
            } else {
                //Inicio. Sin nada
                VStack {
                    #if os(iOS)
                        Divider()
                            .overlay(Color.gray)
                    #endif
                    HStack {
                        Text("RTT: 0us").padding(
                            EdgeInsets(
                                top: 5.0,
                                leading: 5.0,
                                bottom: 5.0,
                                trailing: 5.0
                            )
                        )
                        Spacer()
                        #if os(iOS)
                            Button(
                                action: {  //Trash
                                    if let cluster = qpingAppData.clusterRunning
                                    {
                                        cluster.resetCounter()
                                    }
                                    qpingAppData.actualRTTns = 0.0  // Para resfrescar los datos.
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
                    }
                }
            }
        }
    }
}

#Preview {
    //@EnvironmentObject  var appData: AppData
    ChartNodeView()
}
