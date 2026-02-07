//
//  SideBarView.swift
//  kping-gui
//
//  Created by Alejandro Garcia on 28/1/24.
//
//  Copyright © 2023-2024 Alejandro Garcia <iacobus75@gmail.com>  <alejandro@kayros.uno>
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
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

struct SideBarView: View {
    @Environment(UIState.self) private var UISTATE
    @Environment(\.modelContext) private var modelContext
    @State var showSheetClusterEditor = false
    @State var showingAlertDelete = false
    @State var indexSetToDelete = IndexSet()
    @Query var clustersData: [ClusterK8SData]
    
    /// Warning de eliminacion de cluster.
    private func removeCluster(at indexSet: IndexSet) {
        indexSetToDelete = indexSet
        // Handle the deletion if the user do a swipe on the list
        for index in indexSetToDelete {
            let clusterToDelete = clustersData[index]
            UISTATE.UUIDSelectedCluster = clusterToDelete.id
        }
        showingAlertDelete = true
    
    }
    
    var body: some View {
        @Bindable var uiState: UIState = UISTATE
        VStack {
            VStack(alignment: .center) {
                Image("kping").padding(
                    EdgeInsets(
                        top: 5.0,
                        leading: 5.0,
                        bottom: 5.0,
                        trailing: 5.0
                    )
                )
                Text("\(KPingState.Program) \(KPingState.Version)").padding(
                    EdgeInsets(
                        top: 0.0,
                        leading: 0.0,
                        bottom: 10.0,
                        trailing: 0.0
                    )
                )
            }
            VStack {
                Section("Cluster kubernetes / nodes:") {
                    if clustersData.isEmpty {
                        Text("no cluster or nodes")
                    }
                    else {
                        List( selection: $uiState.UUIDSelectedCluster) {
                            ForEach(clustersData, id: \.id){
                                clusterData in
                                NavigationLink(clusterData.name){
                                    NodeView(UUIDSelectedCluster: clusterData.id).navigationTitle(getSelectedClusterName())
                                }
                                .contextMenu {
                                    Button(
                                        "Edit " + "\(clusterData.name)",
                                        action: {
                                            uiState.editCluster = ClusterK8S(
                                                clusterData: clusterData
                                            )
                                            showSheetClusterEditor = true
                                        }
                                    )
                                    Button(
                                        "Delete " + "\(clusterData.name)",
                                        action: {
                                            uiState.editCluster = ClusterK8S(
                                                clusterData: clusterData
                                            )
                                            showingAlertDelete = true
                                        }
                                    )
                                }
                            }.onDelete(perform: removeCluster)
                            
//                                                        .headerProminence(.increased)
                        }
                    }
                }
            }
            Spacer()
            HStack {
                Button(
                    "Add cluster/node",
                    systemImage: "plus.circle",
                    action: {
                        uiState.editCluster = ClusterK8S()  // dummy
                        showSheetClusterEditor = true
                    }
                )
                .buttonStyle(.plain)
#if os(iOS)
                .padding(
                    EdgeInsets(
                        top: 0.0,
                        leading: 25.0,
                        bottom: 0.0,
                        trailing: 0.0
                    )
                )
#else
                .padding(
                    EdgeInsets(
                        top: 0.0,
                        leading: 0.0,
                        bottom: 0.0,
                        trailing: 0.0
                    )
                )
                .frame(alignment: .trailing)
#endif
                .sheet(isPresented: $showSheetClusterEditor) { ClusterEditorView() }
                .alert("WARNING", isPresented: $showingAlertDelete) {
                    Button("Delete", role: .destructive) {
                        // Handle the deletion if the user push delete button doing a long click or right click
                        if uiState.UUIDSelectedCluster != ClusterK8S.idINVALID {
                            if let index = clustersData.firstIndex(where: {
                                $0.id == uiState.UUIDSelectedCluster
                            }) {
                                modelContext.delete(clustersData[index])
                            }
                        }
                        //Reset path
                        if !uiState.path.isEmpty {
                            uiState.path.removeLast()
                        }
                        // Handle the deletion if the user do a swipe on the list
                        for index in indexSetToDelete {
                            let clusterToDelete = clustersData[index]
                            if uiState.UUIDSelectedCluster != ClusterK8S.idINVALID {
                                //bindSelectedClusterData = ClusterK8SData() //dummy
                            }
                            modelContext.delete(clusterToDelete)
                        }
                        indexSetToDelete = IndexSet()  //indexSet vacio
                    }
                    Button(
                        "Cancel",
                        role: .cancel,
                        action: {  // Dismiss. do nothing.
                        }
                    )
                } message: {
                    Text(
                        "Are you sure to delete this cluster/node '\(getSelectedClusterName()) '?"
                    )
                }
#if os(iOS)
                Spacer()
                Button(
                    action: {
                        uiState.showAboutView = true
                    },
                    label: { Image(systemName: "info.circle") }
                )
                .sheet(isPresented: $uiState.showAboutView) {
                    AboutView()
                }
                .padding(
                    EdgeInsets(
                        top: 0.0,
                        leading: 0.0,
                        bottom: 0.0,
                        trailing: 20.0
                    )
                )
#endif
            }
#if os(macOS)
            .padding(
                EdgeInsets(top: 0.0, leading: 0.0, bottom: 5.0, trailing: 0.0)
            )
#endif
            HStack {
                //3D
#if canImport(UIKit)
                MetalViewIOS(tipoRender: .Mesh_1)
#endif
                
#if canImport(AppKit)
                MetalViewMac(tipoRender: .Mesh_1)
#endif
            }
        }
    }
        
        func getSelectedClusterName() -> String {
            if let index = clustersData.firstIndex(where: {
                $0.id == UISTATE.UUIDSelectedCluster
            }) {
                return clustersData[index].name
            } else {
                return String("none?")
            }
        }
    }

//#Preview {
//    SideBarView()
//        .environment(UIState.shared)
//}

