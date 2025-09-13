//
//  ClusterView.swift
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

import SwiftUI

struct ClusterView: View {
    @EnvironmentObject var qpingAppData: QPingAppData

    let step = 100
    let range = 100...1000
    @State var nodeSelected = 0
    let protocols = ["QUIC+UDP", "Only UDP"]

    #if os(iOS)
        let espaciado = 0.0
    #endif

    #if os(macOS)
        let espaciado = 5.0
    #endif

    var body: some View {

        if let selectedCluster = qpingAppData.selectedCluster {
            //   if let isClusterRunning = (appData.clusterRunning != nil) ? true : false {

            VStack {
                #if os(iOS)
                HStack {
                    //Buttons on iOS, in macos is in title bar, see RootView.
                    Button(
                        action: {  //STOP CLUSTER QPing **************************
                            qpingAppData.runPing = false
                            // 1. Parar
                            if let cluster = qpingAppData.clusterRunning {
                                stopQClientGUI()
                                
                            }
                        },
                        label: {
                            HStack {
                                Text("Stop")
                                Image(systemName: "stop.fill")
                            }
                            .foregroundColor(Color.red)
                        }
                    )
                    
                    .padding(
                        EdgeInsets(
                            top: 0.0,
                            leading: espaciado + 15,
                            bottom: 0.0,
                            trailing: espaciado + 15
                        )
                    )
                    
                    Button(
                        action: {  // RUN CLUSTER QPing *************************
                            qpingAppData.runPing = true
                            
                            //Para cluster anterior
                            if qpingAppData.clusterRunning != nil {
                                // Parar cluster si estaba corriendo?
                                stopQClientGUI()
                            }
                            
                            //Crear nuevo cluster
                            qpingAppData.clusterRunning = ClusterK8S(
                                clusterData: selectedCluster,
                                appData: qpingAppData
                            )
                            
                            do {
                                //Ejecutar QPing
                                //try qpingData.clusterRunning!.runQPing()
                                try runQClientGUI(appData: qpingAppData)
                            } catch {
                                qpingAppData.runPing = false
                            }
                        },
                        label: {
                            HStack {
                                Text("Start")
                                Image(systemName: "play.fill")
                            }
                            .foregroundColor(Color.green)
                        }
                    )
                    //.padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 0.0))
                    .frame(alignment: .leading)
                }
                
                HStack {
                    Picker("Node:", selection: $nodeSelected) {
                        //                        ForEach(selectedCluster.nodes, id: \.self) { colour in
                        //                            Text(colour).tag(id)
                        Text("\(selectedCluster.nodes[0])").tag(0)
                        Text("\(selectedCluster.nodes[1])").tag(1)
                        Text("\(selectedCluster.nodes[2])").tag(2)

                    }
                    .onChange(of: nodeSelected) { newValue in
                        qpingAppData.selectedCluster!.nodeSelected =
                            newValue
                    }

                    
                    Text("Port: \(selectedCluster.port)")
                        //.multilineTextAlignment(.leading)
                        //.padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                        .frame(maxWidth: 93, alignment: .center)
                        //Pick a step
                        Picker("Step:", selection: $qpingAppData.sendIntervalns)
                        {
                            Text("100 ms").tag(100.0 * 1000 * 1000)
                            Text("250 ms").tag(250.0 * 1000 * 1000)
                            Text("500 ms").tag(500.0 * 1000 * 1000)
                            Text("1 sec").tag(1000.0 * 1000 * 1000)
                        }
                    }
                #endif  //BUttons IOS

                #if os(macOS)
                    HStack {
                        Picker("Node:", selection: $nodeSelected) {
                            //                        ForEach(selectedCluster.nodes, id: \.self) { colour in
                            //                            Text(colour).tag(id)
                            Text("\(selectedCluster.nodes[0])").tag(0)
                            Text("\(selectedCluster.nodes[1])").tag(1)
                            Text("\(selectedCluster.nodes[2])").tag(2)

                        }
                        .onChange(of: nodeSelected) { newValue in
                            qpingAppData.selectedCluster!.nodeSelected =
                                newValue
                        }

                        .frame(
                            idealWidth: 180,
                            maxWidth: 200,
                            alignment: .leading
                        )
                        .padding(
                            EdgeInsets(
                                top: 0.0,
                                leading: espaciado,
                                bottom: 0.0,
                                trailing: 0.0
                            )
                        )
                        Text("Port: \(selectedCluster.port)")
                            //.multilineTextAlignment(.leading)
                            //.padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                            .frame(maxWidth: 93, alignment: .center)

                        //Pick a protocol
                        Picker("", selection: $qpingAppData.selectionProtocol) {
                            ForEach(protocols, id: \.self) { item in
                                Text(item)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 250, alignment: .leading)

                        //Pick a step
                        Picker("Step:", selection: $qpingAppData.sendIntervalns)
                        {
                            Text("100 ms").tag(100.0 * 1000 * 1000)
                            Text("250 ms").tag(250.0 * 1000 * 1000)
                            Text("500 ms").tag(500.0 * 1000 * 1000)
                            Text("1 sec").tag(1000.0 * 1000 * 1000)
                        }
                        .frame(maxWidth: 150, alignment: .leading)
                        Spacer()

                    }
                #endif

            }
            .padding(
                EdgeInsets(
                    top: espaciado,
                    leading: 0.0,
                    bottom: 0.0,
                    trailing: 0.0
                )
            )

            if qpingAppData.runPing {
                if let clusterRunning = qpingAppData.clusterRunning {
                    if clusterRunning.id != selectedCluster.id {
                        Spacer()
                        Text("Another cluster running. Please stop it first.")
                        Spacer()
                    } else {
                        DetailClusterView()
                    }
                } else {
                    DetailClusterView()
                }
            } else {
                DetailClusterView()
            }
        } else {
            Text("create or select a cluster/node")
        }
    }
}

#Preview {
    ClusterView()
}
