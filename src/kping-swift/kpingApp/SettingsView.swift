//
//  SettingsView.swift
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

import SwiftUI

struct SettingsView: View {
    
    @Environment(UIState.self) private var uiState
    
    let protocols = ["QUIC+UDP", "Only UDP"]
    
    var body: some View {
//        //@Bindable var bindableUIState: UIState = uiState
//        Group{
//           //Toggle("QUIC/UDP", isOn: $appData.QUIC_UDP)
//            Picker("Protocol:", selection: $bindableUIState.selectionProtocol) {
//                ForEach(protocols, id: \.self ) { item  in
//                    Text(item)
//                }
//            }
//            .pickerStyle(.segmented)
//            Text("Use UDP+QUIC protocol by default.")
//        }
        
        Text("Settings here!")
    }
}

#Preview {
    SettingsView()
        .environment(UIState.shared)
}
