//
//  ClusterView.swift
//  kping-gui
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
import SwiftData

struct NodeView: View {
    @Environment(UIState.self) private var UISTATE
    @Environment(\.modelContext) private var modelContext
    @State var node = 0
    @State var port: String = ""
    @State var kpingProtocol = 0
    @State var sendIntervalns = 1000 * 1000 * 1000 //1seg
    @Query var clustersData: [ClusterK8SData]

    let step = 100
    let range = 100...1000
    let protocols = ["UDP+QUIC", "Only UDP"]

    #if os(iOS)
        let espaciado = 0.0
    #endif

    #if os(macOS)
        let espaciado = 5.0
    #endif

    var body: some View {
        @Bindable var uiState: UIState = UISTATE
        //For TEST
        //let selectedCluster = ClusterK8SData(id: UUID(), name: "local", port: 25450, nodes: ["192.168.2.71","",""])
        if uiState.UUIDSelectedCluster != ClusterK8S.idINVALID && !clustersData.isEmpty {
        // FOR TEST if selectedCluster != nil {
            VStack {
                #if os(iOS)
                HStack {
                    Spacer()
                    //Buttons on iOS, in macos is in title bar, see RootView.
                    Button(
                        action: {  //STOP CLUSTER QPing **************************
                            uiState.runPing = false
                            // 1. Parar
                            if uiState.clusterRunning.id != ClusterK8S.idINVALID {
                                Task {
                                    await uiState.qclient!.stopConnection()                                }
                            }
                        },
                        label: {
                            
                            ZStack {
                                        Circle()
                                    .fill(Color.secondary)
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "stop.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 25))
                                    }
                        }
                    )
                    
                    .padding(
                        EdgeInsets(
                            top: 0.0,
                            leading: espaciado + 15 ,
                            bottom: 0.0,
                            trailing: espaciado + 15
                        )
                    )

                    Spacer()
                    
                    Button(
                        action: {  // RUN CLUSTER QPing *************************
                          
                            
                            //Para cluster anterior
                            if uiState.clusterRunning.id != ClusterK8S.idINVALID {
                                // Parar cluster si estaba corriendo?
                                Task {
                                    await uiState.qclient!.stopConnection()
                                }
                            }
                            
                            //Crear nuevo cluster
                            uiState.clusterRunning = ClusterK8S(
                                clusterData: selectedClusterData,
               
                            )
                            
                            Task {
                                do {
                                    //Ejecutar QPing
                                    //try qpingData.clusterRunning!.runQPing()
                                   
                                    try await uiState.qclient!.start()  //TODO REVISAR
                                    //runQClientGUI(appData: uiState)
                                    uiState.runPing = true
                                    
                                } catch {
                                    uiState.runPing = false
                                }
                            }
                        },
                        label: {
                            ZStack {
                                        Circle()
                                    .fill(Color.secondary)
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "play.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 25))
                                    }
//                            HStack {
//                                //Text("Start")
//                                Image(systemName: "play.fill")
//                            }        .foregroundColor(Color.secondary)
                            //.foregroundColor(Color.green)
                        }
                    )
                    //.padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 0.0))
                    //.frame(alignment: .leading)
                    .frame(alignment: .center)
                    
                    Spacer()
                }
                
                HStack {
                    Picker("Node:", selection: $nodeSelected) {
                        //                        ForEach(selectedCluster.nodes, id: \.self) { colour in
                        //                            Text(colour).tag(id)
                        Text("\(selectedClusterData.nodes[0])").tag(0)
                        Text("\(selectedClusterData.nodes[1])").tag(1)
                        Text("\(selectedClusterData.nodes[2])").tag(2)

                    }
                    .onChange(of: nodeSelected) { newValue in
                        selectedClusterData.nodeSelected =
                            newValue
                    }        .foregroundColor(Color.secondary)

                    
                    Text("Port: \(selectedClusterData.port)")
                        .foregroundColor(Color.secondary)
                        //.multilineTextAlignment(.leading)
                        //.padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                        .frame(maxWidth: 93, alignment: .center)
                        //Pick a step
                    
                    Picker("Step:", selection: $bindableUIState.sendIntervalns)
                    {
                         Text("100 ms").tag(100.0 * 1000 * 1000)
                         Text("250 ms").tag(250.0 * 1000 * 1000)
                         Text("500 ms").tag(500.0 * 1000 * 1000)
                         Text("1 sec").tag(1000.0 * 1000 * 1000)
                    } .foregroundColor(Color.secondary)
                 }
                #endif  //BUttons IOS

                #if os(macOS)
                    HStack {
                        Picker("Node:", selection: $node) {
                            //                        ForEach(selectedCluster.nodes, id: \.self) { colour in
                            //                            Text(colour).tag(id)
                            Text("\(getSelectedClusterData()!.nodes[0])").tag(0)
                            Text("\(getSelectedClusterData()!.nodes[1])").tag(1)
                            Text("\(getSelectedClusterData()!.nodes[2])").tag(2)

                        }
                        .onChange(of: node) { oldValue, newValue in
                            getSelectedClusterData()!.nodeSelected = newValue
                        }

                        .frame(
//                            idealWidth: 180,
//                            maxWidth: 200,
                            alignment: .leading
                        )
                        .padding(
                            EdgeInsets(
                                top: 0.0,
                                leading: espaciado+10,
                                bottom: 0.0,
                                trailing: 0.0
                            )
                        )
                        Text("Port: \(uiState.clusterRunning.clusterData.port)")
                            //.multilineTextAlignment(.leading)
                            //.padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                            .frame(maxWidth: 93, alignment: .center)

                        //Pick a protocol
                        Picker("Protocol:", selection: $kpingProtocol) {
//                            ForEach(protocols, id: \.self) { item in
//                                Text(item)
//                            }
                            Text("UDP+QUIC").tag(0)
                            Text("UDP").tag(1)
                           
                        }
                        //.pickerStyle(.segmented)
                        //.frame(maxWidth: 250, alignment: .leading)

                        //Pick a step
                        Picker("Step:", selection: $sendIntervalns)
                        {
                            Text("1 sec").tag(1000 * 1000 * 1000)
                            Text("500 ms").tag(500 * 1000 * 1000)
                            Text("250 ms").tag(250 * 1000 * 1000)
                            Text("100 ms").tag(100 * 1000 * 1000)
                            Text("50 ms").tag(50 * 1000 * 1000)
                            Text("25 ms").tag(25 * 1000 * 1000)
                            Text("10 ms").tag(10 * 1000 * 1000)
                        }
                        .onChange(of: sendIntervalns) { oldValue, newValue in
                            //getSelectedClusterData()!.step = newValue
                            uiState.clusterRunning.sendIntervalns = Int(newValue)
                        }
                        //.frame(maxWidth: 150, alignment: .leading)
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
            .background(Color(.windowBackgroundColor))

            if uiState.runPing {
                if  uiState.clusterRunning.id != ClusterK8S.idINVALID {
                    if uiState.clusterRunning.id != uiState.UUIDSelectedCluster {
                        Spacer()
                        Text("Another cluster running. Please stop it first.")
                        Spacer()
                    } else {
                        PingNodeView()
                    }
                } else {
                    PingNodeView()
                }
            } else {
                PingNodeView()
            }
        } else {
            Text("create or select a cluster/node")
        }
    }
    
    func getSelectedClusterData() -> ClusterK8SData? {
        if let index = clustersData.firstIndex(where: {$0.id == UISTATE.UUIDSelectedCluster})
        {
             return clustersData[index]
        }
        else
        {
            return nil
        }
    }
    
    func getIndexSelectedClusterData() -> Int? {
        if let index = clustersData.firstIndex(where: {$0.id == UISTATE.UUIDSelectedCluster})
        {
             return index
        }
        else
        {
            return nil
        }
    }
}

//#Preview {
//    NodeView().environment(UIState.shared)
//}
