//
//  QClientGUI.swift
//  qping
//
//  Created by Alejandro on 1/5/25.
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

import Foundation
import Network
import SwiftData
import SwiftUI


// MARK: stopQClient
/// Para cliente QPing
@MainActor
func stopQClientGUI(appData: KPingAppData) async
{
    if let c = appData.qclient{
        await c.stopConnection()
    }
}

// MARK: runQClient
/// Loop para espera de comando start y para ejecucion de qping en loop
@MainActor
func runQClientGUI(appData: KPingAppData)  async throws -> Void {
    
    //if appData ?? { print("QClientGUI: Error cluster not found.") ; return }
    let cluster = appData.clusterRunning  //Do all activity quth the cluster running
    
    guard let cluster else { print("QClientGUI: Error cluster not found.") ; return }
    
    if cluster.clusterData.nodes[cluster.clusterData.nodeSelected] == "" {
        cluster.qpingDataString.append(
            RTTData(
                string: "Error: No node address found.\n",
                id: 0,
                timeReceived: uptime(),
                delay: 0.0
            )
        )
        return
    }

    cluster.qpingDataString.append(
        RTTData(
            string:
                "Connection to: \(cluster.clusterData.nodes[cluster.clusterData.nodeSelected])",
            id: 0,
            timeReceived: uptime(),
            delay: 0.0
        )
    )

    let qclient = QClient(
        host: cluster.clusterData.nodes[cluster.clusterData.nodeSelected],
        port: cluster.clusterData.port)
    
    await qclient.SetClientHandleConnectionStateChanged(handleClientConnectionStateChanged: { state in
          Task { @MainActor in
              clientGUIHandleConnectionStateChanged(to: state)
          }
      })

      await qclient.SetClientHandleClientReceiveData(handleClientReceiveData: { content, contentContext, isComplete, error in
          Task { @MainActor in
              clientGUIHandleReceiveData(content, contentContext, isComplete, error)
          }
      })
    
//    await qclient.SetClientHandleConnectionStateChanged(handleClientConnectionStateChanged: clientGUIHandleConnectionStateChanged)
//    
//    await qclient.SetClientHandleClientReceiveData(handleClientReceiveData: clientGUIHandleReceiveData)
    

    // Set qping client
    appData.qclient = qclient
    
    //Delay between sends and reset all states and counters
    //cluster.delayms = appData.sendIntervalns
    cluster.resetCounter()
    cluster.estadoCluster = "Running"
    cluster.startTime = uptime()
    await appData.qclient!.kping!.setClientLoop(true)
    
    //Run qClient
    Task {
        do {
            //Connect
            try await qclient.start()

            //id
            var iteration: Int64 = 1

            //Bucle
            while await appData.qclient!.kping!.clientLoop {
                //Check network state
                switch await qclient.getConnectionState()
                {
                case .cancelled:
                    printGUI("\(TimeNow()) cancelled connection")
                    break

                case .setup:
                    printGUI("\(TimeNow()) setup connection")

                case .waiting(_):
                    printGUI("\(TimeNow()) waiting connection, reconnecting")

                case .preparing:
                    printGUI("\(TimeNow()) preparing connection")

                case .ready:
                    //Fill rtt
                    let rtt_data = RTTQUIC(
                        Id: iteration,
                        Time_client: Int(
                            Date().timeIntervalSince1970 * 1000 * 1000
                        ),
                        Time_server: 0,
                        Data: KPingState.mensaje_data!
                    )

                    let encoder = JSONEncoder()
                    encoder.dateEncodingStrategy = .millisecondsSince1970

                    let json_data = try encoder.encode(rtt_data)

                    iteration += 1

                case .failed(_):
                    printGUI("\(TimeNow()) connection failed")
                    break

                @unknown default:
                    printGUI("\(TimeNow()) connection failed, unknow state")
                }

                //Espera delaySend ms
                try await Task.sleep(nanoseconds: UInt64(appData.sendIntervalns))
            }

        } catch {
            if error is CancellationError {
                throw error
            } else {
                throw error
            }
        }
    }
}

//MARK: clientGUIHandleConnectionStateChanged
/// CLIENTE GUI: Handle connections state changed
@MainActor
func clientGUIHandleConnectionStateChanged(to state: NWConnection.State)  -> Void  {
    switch state {
    case .waiting(_):
        printGUI(
            "\(TimeNow())* Client connection state changed to WAITING state"
        )
    case .failed(let error):
        printGUI(
            "\(TimeNow())* Client connection state changed to FAILED state"
        )
        clientGUIConnectionFailed(error: error)

    default:
        break
    }
}

//MARK: clientGUIHandleReceiveData
///CLIENTE GUI: Handle receive Data
@MainActor
func clientGUIHandleReceiveData(
    _ content: Data?,
    _ contentContext: NWConnection.ContentContext?,
    _ isComplete: Bool,
    _ error: NWError?
)  -> Void {

    @EnvironmentObject var qpingAppData: KPingAppData
    //    guard let qpingAppData = qpingAppData else {  print("\(TimeNow())clientGUIHandleReceiveData: Error no qpingAppData"); return }
    //    
    guard let cluster = qpingAppData.clusterRunning else {
        print(
            "\(TimeNow())clientGUIHandleReceiveData: Error no cluster no qpingAppData"
        ); return
    }

    
    //Procesar datos recibidos de la conexión
    if let data = content, !data.isEmpty {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            let rtt_result = try decoder.decode(
                RTTQUIC.self,
                from: data
            )
            
            let rtt_time = Double (rtt_result.Time_server - rtt_result.Time_client)
            let now = TimeNow()
            
            //Visualizar el rtt como texto en la GUI
            printGUI("\(now) id=\(rtt_result.Id)  RTT=\(rtt_time)us")
            printDEBUG("\(now) id=\(rtt_result.Id)  RTT=\(rtt_time)us")
            
            //Visualizar el rtt actual
            qpingAppData.actualRTTns = rtt_time
            
            //Visualizar el rtt
            qpingAppData.actualRTTns = rtt_time
            if rtt_time > qpingAppData.maxRTTns { qpingAppData.maxRTTns = rtt_time }
            if rtt_time < qpingAppData.minRTTns || qpingAppData.minRTTns == 0 { qpingAppData.minRTTns = rtt_time }
           
            //Media rtt
            let nuevaCantidadNumeros = Double (cluster.qpingDataChart.count + 1)
            qpingAppData.medRTTns = qpingAppData.medRTTns == 0 ? rtt_time :
            ((qpingAppData.medRTTns * Double(cluster.qpingDataChart.count)) + rtt_time) / nuevaCantidadNumeros
            
            //Actualizar datos del chart
            cluster.qpingDataChart.append(
                 RTTData(
                     string: "",
                     id: rtt_result.Id,
                     timeReceived: uptime(),
                     delay: rtt_time
                 )
             )
             
        } catch {
            printGUI("Unexpected error: \(error).")
        }
    }

    //Conexión completada/finalizada
    if isComplete {
        clientGUIConnectionEnded(error: error)
        return
    }

    //Error en la conexion
    if let error = error {
        clientGUIConnectionFailed(error: error)
        return
    }

    //Registrar de nuevo el handler
    //Establecer handle de recepción
    Task { await qpingAppData.qclient!.registerReceiveHandler(
        minimumIncompleteLength: 1,
        maximumLength: KPingState.MTU,
        completion:
            {
                (content, contentContext, isComplete , error) in
                Task { @MainActor in
                    clientGUIHandleReceiveData(content, contentContext, isComplete , error)
                }
            }
    )
    }
}


///GENERAL:  function to print  to GUI
@MainActor
func printGUI(_ cadena: String) {
   
    @EnvironmentObject var qpingAppData: KPingAppData
    
    Task {
    guard let cluster = qpingAppData.clusterRunning else {  print("PrintGUI: Error no qpingAppData"); return }

        await cluster.qpingDataString.append(
        RTTData(
            string: cadena,
            id: (qpingAppData.qclient?.kping?.print_id)!,
            timeReceived: uptime(),
            delay: 0.0
        )
    )
    await qpingAppData.qclient?.kping!.incPrintId()
    //Update timestamp for GUI
        await qpingAppData.qclient?.kping!.qpingAppData?.setTimeStamp(timestamp: TimeNow())
        
    }
}


/// CLIENT: Connection failed callback
@MainActor
func clientGUIConnectionFailed(error: Error) {
    @EnvironmentObject var qpingAppData: KPingAppData
    printGUI("connection failed: " + error.localizedDescription)

    //Para loop
    Task {
        await qpingAppData.qclient?.kping!.setClientLoop(false)
    }
}

/// CLIENT: Connection ended callback
@MainActor
func clientGUIConnectionEnded(error: Error?) {
    @EnvironmentObject var qpingAppData: KPingAppData
    if error != nil {
        printGUI("connection ended: " + error!.localizedDescription)
    } else {
        printGUI("connection ended")
    }

    //Para loop
    Task {
        await qpingAppData.qclient?.kping!.setClientLoop(false)
    }
}


/// CLIENT: Send  callback.
func clientGUISendCompleted(error: Error?) {
    @EnvironmentObject var qpingAppData: KPingAppData
    if error != nil {
        printGUI("Send error: " + error!.localizedDescription)
        
        //Para loop
        Task {
            await qpingAppData.qclient?.kping!.setClientLoop(false)
        }
    }
}
