//
//  qping_guiApp.swift
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
import CoreTelephony



///
/// App QPing
///
@main
struct QPingApp: App {
    //AppData para guardar estado de la aplicacion entre vistas
    @StateObject private var qpingData = QPingAppData(path: NavigationPath())
#if os(iOS)
private var info: CTTelephonyNetworkInfo!
#endif

    var body: some Scene {
        
        //Window group principal
        WindowGroup {
            RootView()
                .modelContainer(for: [
                    ClusterK8SData.self
                ])
                .environment(qpingData)
                .preferredColorScheme(.dark)
                .onAppear()
#if os(macOS)
                .frame(minWidth: 600, minHeight: 400)
                
#endif
        }
        
        //Window group secundario de prueba.
        WindowGroup("Content") {
            ContentView2()
        }
        
#if os(macOS)
        // Settings window
        Settings() {
            SettingsView()
        }  .environment(qpingData)
#endif
    }
    
    
//    
//#if os(iOS)
//
//mutating func createObserver() {
//    info = CTTelephonyNetworkInfo();
//    NotificationCenter.default.addObserver(self, selector: "currentAccessTechnologyDidChange",
//                                           name: NSNotification.Name.CTRadioAccessTechnologyDidChange, object: <#Any?#>) //, object: observerObject)
//}
//
//func currentAccessTechnologyDidChange() {
//    if let currentAccess = self.info.currentRadioAccessTechnology {
//        switch currentAccess {
//        case CTRadioAccessTechnologyGPRS:
//            print("GPRS")
//        case CTRadioAccessTechnologyEdge:
//            print("EDGE")
//        case CTRadioAccessTechnologyWCDMA:
//            print("WCDMA")
//        case CTRadioAccessTechnologyHSDPA:
//            print("HSDPA")
//        case CTRadioAccessTechnologyHSUPA:
//            print("HSUPA")
//        case CTRadioAccessTechnologyCDMA1x:
//            print("CDMA1x")
//        case CTRadioAccessTechnologyCDMAEVDORev0:
//            print("CDMAEVDORev0")
//        case CTRadioAccessTechnologyCDMAEVDORevA:
//            print("CDMAEVDORevA")
//        case CTRadioAccessTechnologyCDMAEVDORevB:
//            print("CDMAEVDORevB")
//        case CTRadioAccessTechnologyeHRPD:
//            print("HRPD")
//        case CTRadioAccessTechnologyLTE:
//            print("LTE")
//        default:
//            print("DEF")
//        }
//    } else {
//        print("Current Access technology is NIL")
//    }
//}
//
//#endif

}
