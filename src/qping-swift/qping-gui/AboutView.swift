//
//  AboutView.swift
//  qping-gui
//
//  Created by Alejandro Garcia on 28/1/24.
//
//
// Copyright © 2023-2024 Alejandro Garcia <iacobus75@gmail.com>  <alejandro@kayros.uno>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


import SwiftUI

struct AboutView: View {
    @EnvironmentObject  var appData: QPingAppData
    
    var body: some View {
        Text("")
        Text("\(QPing.Program)")
        Text("version: \(QPing.Version)")
        Text("")
        Text("Alejandro Garcia - 2024")
        //Text("github/kayrosuno")
        Text("")
        Text("""
                 qping is a ping utility for the QUIC protocol available in go and Swift.
                 
                 qping support RFC 9000 QUIC: A UDP-Based Multiplexed and Secure Transport
                 
                 Available implementation in go and swift help to test 5G networks low latency using QUIC protocols, measure RTT, MTU and Bandwith. go implementations are suitable for use in machines running Linux or macOS while swift implementation is helpfull to do the test over iOS devices with 5G connectivity as well as macOS
                 
                 
                 To **learn more**, *please* feel free to visit [Github page](https://github.com/kayrosuno/qping) for details.
                 
                 
                 """
        ).padding(20)
       
        Button("OK"){  appData.showAboutView = false}.padding(20).tint(.accentColor)
    }
}

#Preview {
    AboutView()
}
