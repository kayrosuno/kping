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

struct QPingView: View {
    @EnvironmentObject var qpingAppData: QPingAppData

    #if os(iOS)
        let espaciado = 0.0
    #endif

    #if os(macOS)
        let espaciado = 5.0
    #endif

    var body: some View {
        VStack {
            if let clusterRunning = qpingAppData.clusterRunning {
                VStack {
#if os(iOS)
    Divider()
        .overlay(Color.gray)
#endif
                    HStack {
                        Text("\(qpingAppData.timestamp)")
                        Spacer()
#if os(iOS)
                        Button(
                            action: {  //Trash
                                if let cluster = qpingAppData.clusterRunning {
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
                        ForEach(clusterRunning.qpingDataString) { item in
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
}

//#Preview {
//    @EnvironmentObject  var qpingAppData: QPingAppData
//    QPingView()
//}
