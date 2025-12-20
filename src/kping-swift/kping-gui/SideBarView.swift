//
//  SideBarView.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 28/1/24.
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

struct SideBarView: View {
    @EnvironmentObject  var qpingAppData: QPingAppData
    @Environment(\.modelContext) private var modelContext
    @State var showSheetClusterEditor = false
    @State var showingAlertDelete = false
    @State var indexSetToDelete = IndexSet()
    @Query var clusters: [ClusterK8SData]
    
    /// Warning de eliminacion de cluster.
    private func removeCluster(at indexSet: IndexSet) {
        showingAlertDelete = true
        indexSetToDelete = indexSet
    }
    
    var body: some View {
         
        VStack{
            VStack(alignment: .center){
                Image("qping").padding(EdgeInsets(top: 5.0,leading: 5.0,bottom: 5.0,trailing: 5.0))
                Text("\(QPing.Program) \(QPing.Version)").padding(EdgeInsets(top: 0.0,leading: 0.0,bottom: 10.0,trailing: 0.0))
                // .onAppear() {appData.sidebarbackground = self.background()}
            }
                VStack
                {
                    List(selection: $qpingAppData.selectedCluster){
                        Section("Cluster kubernetes / nodes:")
                        {
                            if(clusters.isEmpty) {
                                Text("no cluster or nodes")
                            }
                            else {
                                ForEach(clusters, id: \.self) { cluster in
                                    NavigationLink(cluster.name, value: cluster.id)
                                        .contextMenu {
                                            Button("Edit "+"\(cluster.name)", action: {
                                                qpingAppData.editCluster = cluster
                                                qpingAppData.selectedCluster = cluster
                                                showSheetClusterEditor=true  })
                                            Button("Delete "+"\(cluster.name)", action: {
                                                qpingAppData.editCluster = nil
                                                showingAlertDelete = true
                                                qpingAppData.selectedCluster = cluster })
                                        }
                                }
                                .onDelete(perform: removeCluster)
                                .headerProminence(.increased)
                            }
                    }
                    .listStyle(.sidebar)
                    }
                Spacer()
                    HStack{

                        Button("Add cluster", systemImage: "plus.circle", action: {
                            qpingAppData.editCluster = nil
                            showSheetClusterEditor = true
                        })
                        
                        .buttonStyle(.plain)
        #if os(iOS)
                            .padding(EdgeInsets(top: 0.0,leading: 25.0,bottom: 0.0,trailing: 0.0))
        #else
                            .padding(EdgeInsets(top: 0.0,leading: 0.0,bottom: 0.0,trailing: 0.0))
                            .frame(alignment: .trailing)
        #endif
                            .sheet(isPresented:  $showSheetClusterEditor){ ClusterEditorView()}
                            .alert("WARNING", isPresented: $showingAlertDelete) {
                                Button("Delete", role: .destructive) {
                                    
                                    // Handle the deletion if the user push delete button doing a long click or right click
                                    if qpingAppData.selectedCluster != nil {
                                        modelContext.delete(qpingAppData.selectedCluster!)
                                        
                                        //Reset path
                                        if(!qpingAppData.path.isEmpty){
                                            qpingAppData.path.removeLast()
                                        }
                                        qpingAppData.path.append(qpingAppData.selectedCluster!.name) //Se pasa el String para que lo muestre el NavigationStack utilizando el .navigationDestination de tipo String
                                    }
                                    
                                    // Handle the deletion if the user do a swipe on the list
                                    for index in indexSetToDelete {
                                        let clusterToDelete = clusters[index]
                                        if qpingAppData.selectedCluster?.persistentModelID == clusterToDelete.persistentModelID {
                                            qpingAppData.selectedCluster = nil
                                        }
                                        modelContext.delete(clusterToDelete)
                                    }
                                    
                                    indexSetToDelete = IndexSet() //indexSet vacio
                                 }
                                Button("Cancel", role:.cancel, action: { // Dismiss. do nothing.
                                })
                                
                            }  message: {
                                Text("Are you sure to delete this cluster/node?")
                            }
        #if os(iOS)
                        Spacer()
                        Button(action: {
                            qpingAppData.showAboutView = true
                        },label: {Image(systemName: "info.circle")})
                        .sheet(isPresented: $qpingAppData.showAboutView){ AboutView() }
                        .padding(EdgeInsets(top: 0.0,leading: 0.0,bottom: 0.0,trailing: 20.0))
        #endif
                    }
        #if os(macOS)
                    .padding(EdgeInsets(top: 0.0,leading: 0.0,bottom: 5.0,trailing: 0.0))
        #endif
                }
            }
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

struct SideBarView_Previews: PreviewProvider {
    @EnvironmentObject  var appData: QPingAppData
    static var previews: some View {
        SideBarView()
    }
}
