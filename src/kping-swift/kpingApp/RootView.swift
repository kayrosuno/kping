//
//  RootView.swift
//  kping-gui
//
//  Created by Alejandro Garcia on 28/1/24.
//
//  Copyright © 2023-2026 Alejandro Garcia <iacobus75@gmail.com>  <alejandro@kayros.uno>
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

struct RootView: View {
    @Environment(UIState.self) private var UISTATE
    @State private var showingAlert = false
    @State private var preferredColumn = NavigationSplitViewColumn.sidebar

    @Query var clustersData: [ClusterK8SData]

    var body: some View {
        @Bindable var uiState: UIState = UISTATE

        #if os(iOS)
            NavigationStack(path: $uiState.path) {
                SideBarView()
            }
        #else
            NavigationSplitView {
                SideBarView()
            } detail: {
                NavigationStack(path: $uiState.path) {
                    if UISTATE.UUIDSelectedCluster == nil {
                        Text("No node")
                    } else {
                        NodeView(
                            UUIDSelectedCluster: UISTATE.UUIDSelectedCluster!
                        )
                    }
                }
            }
            .sheet(isPresented: $uiState.showAboutView) { AboutView() }
            .toolbar {
                ToolbarItem {  //Info
                    Button(
                        action: {
                            uiState.showAboutView = true
                        },
                        label: { Image(systemName: "info.circle") }
                    )
                }
                ToolbarItem {
                    Button(
                        action: {  // RUN CLUSTER QPing *************************
                            //uiState.clusterRunning.resetCounter()

                            //Para cluster anterior si esta ejecutandose
                            if uiState.clusterRunning.id != ClusterK8S.idINVALID
                            {
                                // Parar cluster si estaba corriendo?
                                // Task{ await stopQClientGUI(appData: uiState) }
                                if let qclient = uiState.clusterRunning.qclient
                                {
                                    qclient.stopConnection()
                                }
                            }

                            if UISTATE.UUIDSelectedCluster
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
                                    if uiState.clusterRunning.clusterData.nodes[
                                        uiState.clusterRunning.clusterData
                                            .nodeSelected
                                    ] == "" {
                                        uiState.clusterRunning.kpingDataString
                                            .append(
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
                                                timeReceived: TimeNowDouble(),
                                                delay: 0.0,
                                                rtt: 0.0
                                            )
                                        )

                                    let qclient = QClient(
                                        host: uiState.clusterRunning.clusterData
                                            .nodes[
                                                uiState.clusterRunning
                                                    .clusterData.nodeSelected
                                            ],
                                        port: uiState.clusterRunning.clusterData
                                            .port
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
                }
                ToolbarItem {
                    Button(
                        action: {  //STOP CLUSTER QPing **************************
                            uiState.runPing = false
                            // 1. Parar
                            if uiState.clusterRunning.id != ClusterK8S.idINVALID
                            {
                                Task {
                                    //                            //await stopQClientGUI(appData: uiState)
                                    //                        }
                                    if let qclient = uiState.clusterRunning
                                        .qclient
                                    {
                                        await qclient.stopConnection()
                                    }
                                }
                            }

                            //qpingAppData.clusterRunning = nil

                        },
                        label: {
                            HStack {
                                Text("Stop")
                                Image(systemName: "stop.fill")
                            }
                            .foregroundColor(Color.secondary)
                        }
                    )

                }
                ToolbarItem {
                    Button(
                        action: {  //Trash
                            if uiState.clusterRunning.id != ClusterK8S.idINVALID
                            {
                                // cluster.qpingOutputNode=[QPingData(string: "", timeReceived: uptime(), delay: 0.0)]
                                uiState.clusterRunning.resetCounter()
                            }
                            //cluster.actualRTT = 0.0 // Para resfrescar los datos.
                        },
                        label: {
                            HStack {
                                Text("Clear")
                                Image(systemName: "trash")
                            }
                            .foregroundColor(Color.secondary)
                        }
                    )
                }
                //.navigationTitle(getSelectedClusterName())
            }
            .navigationTitle(getSelectedClusterName())
        #endif

    }

    func getSelectedClusterName() -> String {
        if let index = clustersData.firstIndex(where: {
            $0.id == UISTATE.UUIDSelectedCluster
        }) {
            return clustersData[index].name
        } else {
            return String(KPingState.Program + " " + KPingState.Version)
        }
    }

    func getSelectedClusterData() -> ClusterK8SData? {
        if let index = clustersData.firstIndex(where: {
            $0.id == UISTATE.UUIDSelectedCluster
        }) {
            return clustersData[index]
        } else {
            return nil
        }
    }
}

//#Preview {
//    RootView().environment(UIState.shared)
//}
