//
//  ClusterEditorView.swift
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


//
//   View para crear o editar cluster. Se edita si el cluster de edición está en la propiedad appData.editCluster, si es nil se añade
//
struct ClusterEditorView: View {
    @EnvironmentObject  var appData: QPingAppData
    @State private var cluster_name = ""
    @State private var port_qping = ""
    @State private var node1_ip = ""
    @State private var node2_ip = ""
    @State private var node3_ip = ""
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    private var editorTitle: String {
        appData.editCluster == nil ? "Add Cluster" : "Edit Cluster"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Cluster settings:") {
                    VStack{
                        TextField("Cluster Name:", text: $cluster_name)
                        TextField("Port qping server:", text: $port_qping)
                        TextField("Node1 IP:", text: $node1_ip)
                        TextField("Node2 IP:", text: $node2_ip)
                        TextField("Node3 IP:", text: $node3_ip)
                        
                    }
#if os(macOS)
                    .padding(EdgeInsets(top: 15.0,leading: 15.0,bottom: 15.0,trailing: 15.0))
#endif
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(editorTitle)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        withAnimation {
                            save()
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                //Check si editamos o dejamos los valores por defecto
                if let cluster = appData.editCluster {
                    // Edit the incoming cluster
                    cluster_name = cluster.name
                    port_qping = String(cluster.port)
                    node1_ip = cluster.nodes[0]
                    node2_ip = cluster.nodes[1]
                    node3_ip = cluster.nodes[2]
                }
            }
        }
#if os(macOS)
        .frame(width: 400,height: 200,alignment: .leading)
#endif
    }//body
    
    func save() {
        
        let sPort = UInt16 (port_qping) ?? UInt16(QPing.portDefault)!
        if let cluster = appData.editCluster {
            // Edit the cluster
            cluster.name = cluster_name
            cluster.port = sPort
            cluster.nodes[0] = node1_ip
            cluster.nodes[1] = node2_ip
            cluster.nodes[2] = node3_ip
            
            //update!!
            
        } else {
            //Add a new cluster
            let newCluster = ClusterK8SData(id: UUID(), name: cluster_name, port: sPort, nodes: [node1_ip,node2_ip,node3_ip])
            modelContext.insert(newCluster)
        }
    }
}//struct

//#Preview {
//    ClusterEditorView()
//}
