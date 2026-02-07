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

import SwiftData
import SwiftUI

struct NodeView: View {
    @Environment(UIState.self) private var UISTATE
    @Environment(\.modelContext) private var modelContext
    @State private var showingAlert = false
    @State var node = 0
    @State var port: String = ""
    @State var kpingProtocol = 0
    @State var sendIntervalns = 1000 * 1000 * 1000  //1seg
    @Query var clustersData: [ClusterK8SData]

    var UUIDSelectedCluster: UUID
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
        if UUIDSelectedCluster != ClusterK8S.idINVALID
            && !clustersData.isEmpty
        {
            // FOR TEST if selectedCluster != nil {
            VStack {
    #if os(iOS)
                    HStack {
                        Spacer()
                        Button(
                            action: {  //STOP CLUSTER QPing **************************
                                uiState.runPing = false
                                // 1. Parar
                                if uiState.clusterRunning.id
                                    != ClusterK8S.idINVALID
                                {
                                    Task {
                                        if let qclient = uiState.clusterRunning
                                            .qclient
                                        {
                                            await qclient.stopConnection()
                                        }
                                    }
                                }
                            },
                            label: {
                                HStack {
                                    Text("Stop")
                                    Image(systemName: "stop.fill")
                                }
                                .foregroundColor(Color.secondary)
                            }
                        )
                        Spacer()

                        Button(
                            action: {  // RUN CLUSTER QPing *************************
                                //Para cluster anterior si esta ejecutandose
                                if uiState.clusterRunning.id
                                    != ClusterK8S.idINVALID
                                {
                                    // Parar cluster si estaba corriendo?
                                    // Task{ await stopQClientGUI(appData: uiState) }
                                    if let qclient = uiState.clusterRunning
                                        .qclient
                                    {
                                        qclient.stopConnection()
                                    }
                                }

                                if UUIDSelectedCluster
                                    == ClusterK8S.idINVALID
                                {
                                    //Ningun cluster seleccionado.
                                    //TODO: popup warning
                                    showingAlert = true
                                    return
                                }

                                //Crear nuevo cluster
                                uiState.runPing = true
                                uiState.clusterRunning = ClusterK8S(
                                    clusterData: getSelectedClusterData()!
                                )

                                Task(name: "runQClientGUI2") {
                                    do {
                                        if uiState.clusterRunning.clusterData
                                            .nodes[
                                                uiState.clusterRunning
                                                    .clusterData.nodeSelected
                                            ] == ""
                                        {
                                            uiState.clusterRunning
                                                .kpingDataString.append(
                                                    RTTData(
                                                        string:
                                                            "Error: No node address found.\n",
                                                        //                                                    id: 0,
                                                        timeReceived:
                                                            TimeNowDouble(),
                                                        delay: 0.0,
                                                        rtt: 0.0
                                                    )
                                                )
                                            return
                                        }

                                        uiState.clusterRunning.kpingDataString
                                            .append(
                                                RTTData(
                                                    string:
                                                        "Connecting to: \( uiState.clusterRunning.clusterData.nodes[ uiState.clusterRunning.clusterData.nodeSelected])",
                                                    //                                                id: 0,
                                                    timeReceived:
                                                        TimeNowDouble(),
                                                    delay: 0.0,
                                                    rtt: 0.0
                                                )
                                            )

                                        let qclient = QClient(
                                            host: uiState.clusterRunning
                                                .clusterData.nodes[
                                                    uiState.clusterRunning
                                                        .clusterData
                                                        .nodeSelected
                                                ],
                                            port: uiState.clusterRunning
                                                .clusterData.port
                                        )

                                        await qclient.setFlagGUI(isGUI: true)
                                        await qclient
                                            .SetClientHandleConnectionStateChanged(
                                                handleClientConnectionStateChanged: {
                                                    state in
                                                    Task { @MainActor in
                                                        qclient
                                                            .clientGUIHandleConnectionStateChanged(
                                                                to: state
                                                            )
                                                    }
                                                })

                                        await qclient
                                            .SetClientHandleClientReceiveData(
                                                handleClientReceiveData: {
                                                    content,
                                                    contentContext,
                                                    isComplete,
                                                    error in
                                                    Task { @MainActor in
                                                        qclient
                                                            .clientGUIHandleReceiveData(
                                                                content,
                                                                contentContext,
                                                                isComplete,
                                                                error
                                                            )
                                                    }
                                                })

                                        //    await qclient.SetClientHandleConnectionStateChanged(handleClientConnectionStateChanged: clientGUIHandleConnectionStateChanged)
                                        //
                                        //    await qclient.SetClientHandleClientReceiveData(handleClientReceiveData: clientGUIHandleReceiveData)

                                        // Set qping client
                                        uiState.clusterRunning.qclient = qclient

                                        //Delay between sends and reset all states and counters
                                        //cluster.delayms = appData.sendIntervalns
                                        //qquiState.clusterRunning.resetCounter()
                                        uiState.clusterRunning.estadoCluster =
                                            "Running"
                                        //uiState.clusterRunning.startTime = uptime()
                                        //await appData.qclient!.kping!.setClientLoop(true)

                                        //Start client qClient
                                        try await qclient.start()

                                        //Ejecutar QPing
                                        //try  await runQClientGUI( appData: uiState )
                                    } catch {
                                        uiState.runPing = false
                                    }
                                }
                            },
                            label: {
                                HStack {
                                    Text("Start")
                                    Image(systemName: "play.fill")
                                }
                                .foregroundColor(Color.secondary)
                            }
                        )
                        .alert(
                            "No cluster or node selected",
                            isPresented: $showingAlert
                        ) {
                            Button("OK") {}
                        }

                        //.padding(EdgeInsets(top: 0.0,leading: 20.0,bottom: 0.0,trailing: 0.0))
                        //.frame(alignment: .leading)
                        .frame(alignment: .center)
                       Spacer()
                    }
                Divider()
                HStack {
                        Text("Node:")
                        Picker("Node:", selection: $node) {
                            //                        ForEach(selectedCluster.nodes, id: \.self) { colour in
                            //                            Text(colour).tag(id)

                            if let cluster = getSelectedClusterData() {
                                Text("\(cluster.nodes[0])").tag(0)
                                Text("\(cluster.nodes[1])").tag(1)
                                Text("\(cluster.nodes[2])").tag(2)
                            }
                        }
                        .onChange(of: node) { oldValue, newValue in
                            if let cluster = getSelectedClusterData() {
                                cluster.nodeSelected = newValue
                            }
                        }
                        .frame(
                            //                            idealWidth: 180,
                            //                            maxWidth: 200,
                            alignment: .leading
                        )
                        .padding(
                            EdgeInsets(
                                top: 0.0,
                                leading: espaciado + 10,
                                bottom: 0.0,
                                trailing: 0.0
                            )
                        )
                    Spacer()
                }
                Divider()
                #endif
//                HStack {
//                    Picker("Node:", selection: $node) {
//                        //                        ForEach(selectedCluster.nodes, id: \.self) { colour in
//                        //                            Text(colour).tag(id)
//                        
//                        if let cluster = getSelectedClusterData() {
//                            Text("\(cluster.nodes[0])").tag(0)
//                            Text("\(cluster.nodes[1])").tag(1)
//                            Text("\(cluster.nodes[2])").tag(2)
//                        }
//                    }
//                    .onChange(of: node) { oldValue, newValue in
//                        if let cluster = getSelectedClusterData() {
//                            cluster.nodeSelected = newValue
//                        }
//                    }
//                    .foregroundColor(Color.secondary)
//                    Text("Port: \(uiState.clusterRunning.clusterData.port)")
//                    //.multilineTextAlignment(.leading)
//                    //.padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
//                        .foregroundColor(Color.secondary)
//                    //.multilineTextAlignment(.leading)
//                    //.padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
//                        .frame(maxWidth: 93, alignment: .center)
//                } .frame( alignment: .leading)
//                HStack {
//                        //Pick a protocol
//                        Picker("Protocol:", selection: $kpingProtocol) {
//                            //                            ForEach(protocols, id: \.self) { item in
//                            //                                Text(item)
//                            //                            }
//                            Text("UDP+QUIC").tag(0)
//                            Text("UDP").tag(1)
//                        }                        //Pick a step
//                        //Pick a step
//                        Picker("Step:", selection: $sendIntervalns) {
//                            Text("1 sec").tag(1000 * 1000 * 1000)
//                            Text("500 ms").tag(500 * 1000 * 1000)
//                            Text("250 ms").tag(250 * 1000 * 1000)
//                            Text("100 ms").tag(100 * 1000 * 1000)
//                            Text("50 ms").tag(50 * 1000 * 1000)
//                            Text("25 ms").tag(25 * 1000 * 1000)
//                            Text("10 ms").tag(10 * 1000 * 1000)
//                        }
//                        .onChange(of: sendIntervalns) { oldValue, newValue in
//                            //getSelectedClusterData()!.step = newValue
//                            uiState.clusterRunning.sendIntervalns = Int(
//                                newValue
//                            )
//                        }
//                        .foregroundColor(Color.secondary)
//                    }.frame( alignment: .leading)
//                #endif  //BUttons IOS
//
//                #if os(macOS)
                    HStack {
#if os(macOS)
                        Picker("Node:", selection: $node) {
                            //                        ForEach(selectedCluster.nodes, id: \.self) { colour in
                            //                            Text(colour).tag(id)

                            if let cluster = getSelectedClusterData() {
                                Text("\(cluster.nodes[0])").tag(0)
                                Text("\(cluster.nodes[1])").tag(1)
                                Text("\(cluster.nodes[2])").tag(2)
                            }
                        }
                        .onChange(of: node) { oldValue, newValue in
                            if let cluster = getSelectedClusterData() {
                                cluster.nodeSelected = newValue
                            }
                        }
                        .frame(
                            //                            idealWidth: 180,
                            //                            maxWidth: 200,
                            alignment: .leading
                        )
                        .padding(
                            EdgeInsets(
                                top: 0.0,
                                leading: espaciado + 10,
                                bottom: 0.0,
                                trailing: 0.0
                            )
                        )
#endif
                        if let cluster = getSelectedClusterData() {
                            Text("Port: \(cluster.port)")
                            //.multilineTextAlignment(.leading)
                            //.padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                               // .frame(maxWidth: 93, alignment: .leading)
                        }
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
                        Picker("Step:", selection: $sendIntervalns) {
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
                            uiState.clusterRunning.sendIntervalns = Int(
                                newValue
                            )
                        }
                        //.frame(maxWidth: 150, alignment: .leading)
                        Spacer()
                    }
             //   #endif
            }
            .padding(
                EdgeInsets(
                    top: espaciado,
                    leading: 0.0,
                    bottom: 0.0,
                    trailing: 0.0
                )
            )
            //  .background(Color())

            if uiState.runPing {
                if uiState.clusterRunning.id != ClusterK8S.idINVALID {
                    if uiState.clusterRunning.id != UUIDSelectedCluster
                    {
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
        if let index = clustersData.firstIndex(where: {
            $0.id == UUIDSelectedCluster
        }) {
            return clustersData[index]
        } else {
            return nil
        }
    }

    func getIndexSelectedClusterData() -> Int? {
        if let index = clustersData.firstIndex(where: {
            $0.id == UUIDSelectedCluster
        }) {
            return index
        } else {
            return nil
        }
    }
}

//#Preview {
//    NodeView().environment(UIState.shared)
//}
