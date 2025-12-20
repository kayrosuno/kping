//
//  QClient.swift
//  
//
//  Created by Alejandro Garcia on 16/5/23.
//
//
//  Copyright © 2023-2025 Alejandro Garcia <iacobus75@gmail.com>  <alejandro@kayros.uno>
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

/// Clase QClient encapsula las funcionalidades de un cliente utilizando el protocolo QUIC con UDP y con TLS
@available(macOS 12, *)
@available(iOS 15, *)
struct QClient {

    /// remote host
    private let host: NWEndpoint.Host
    /// remote port
    private let port: NWEndpoint.Port
    /// Networking queue for receive events
    private let networkQueue: DispatchQueue
    /// Network connection using QUIC
    private let nwConnection: NWConnection

   
    ///Initialize the network connection, creacte DispatchQueue and nwConnection
    init(
        host: String,
        port: UInt16,
        handleClientConnectionStateChanged: @Sendable @escaping (NWConnection.State) -> Void,
        handleClientReceiveData: @Sendable @escaping (
            Data?, NWConnection.ContentContext?, Bool?, NWError?
        )  -> Void
    ) {

        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(rawValue: port)!

        //NetworkQueue
        networkQueue = DispatchQueue(label: "uno.kayros.networking")

        //Parámetros de QUIC
        let quicOptions = NWProtocolQUIC.Options(alpn: ["kayros.uno"])
        quicOptions.direction = .bidirectional
        quicOptions.idleTimeout = QPing.CONNECTION_TIMEOUT
        let securityProtocolOptions: sec_protocol_options_t = quicOptions
            .securityProtocolOptions
        sec_protocol_options_set_verify_block(
            securityProtocolOptions,
            {
                (
                    _: sec_protocol_metadata_t,
                    _: sec_trust_t,
                    complete: @escaping sec_protocol_verify_complete_t
                ) in
                complete(true)
            },
            networkQueue
        )
        let quicParameter = NWParameters(quic: quicOptions)

        //Network connection
        nwConnection = NWConnection(
            host: self.host,
            port: self.port,
            using: quicParameter
        )

        //handle de cambio de estado
        nwConnection.stateUpdateHandler = handleClientConnectionStateChanged

        //Establecer la funcion de recepción
        nwConnection.receive(
            minimumIncompleteLength: 1,
            maximumLength: QPing.MTU,
            completion: handleClientReceiveData
        )
    }

    ///Start connection of the internal nwConnection
    func startConnection()  {
        //Iniciar conexion
        nwConnection.start(queue: networkQueue)
    }

    /// Stop internal nwConnection
    func stopConnection() {
        self.nwConnection.stateUpdateHandler = nil
        self.nwConnection.cancel()
    }
    
    ///Return state of the internal nwConnection
    func getConnectionState() -> NWConnection.State {
        return nwConnection.state
    }

    ///Send data using internal nwConnection
    func send(data: Data, completion: @escaping @Sendable (NWError?) -> Void)
    {
        //TODO: Check state
        nwConnection.send(
            content: data,
            completion: .contentProcessed(completion)
        )
    }

    /// Register  handler for data handler reception
    func registerReceiveHandler(
        minimumIncompleteLength: Int,
        maximumLength: Int,
        completion: @escaping @Sendable (
            _ content: Data?, _ contentContext: NWConnection.ContentContext?,
            _ isComplete: Bool, _ error: NWError?
        ) -> Void
    ) {
        self.nwConnection.receive(
            minimumIncompleteLength: minimumIncompleteLength,
            maximumLength: maximumLength,
            completion: completion
        )
    }

}



///CLIENTE CLI: Handle estado conexion
func clientCLIHandleConnectionStateChanged(to state: NWConnection.State) {
    switch state {
    case .waiting(_):
        //connectionFailed(error: error)
        print("* Client connection state changed to WAITING state")
    case .failed(let error):
        print("* Client connection state changed to FAILED state")
        clientCLIConnectionFailed(error: error)

    default:
        break
    }
}

///CLIENTE: Handle receive Data
@Sendable func clientCLIHandleReceiveData(
    _ content: Data?,
    _ contentContext: NWConnection.ContentContext?,
    _ isComplete: Bool?,
    _ error: NWError?
) {

    //Procesar datos recibidos de la conexión
    if let data = content, !data.isEmpty {
        //TEST let message = String(data: data, encoding: .utf8)
        // TEST print("<< \(message ?? "-")")  /*data: \(data as NSData)*/
        // Swift.print("#",terminator: "")
        //fflush(__stdoutp)
        //self.send(data: data)

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            let rtt_result = try decoder.decode(
                RTTQUIC.self,
                from: data
            )

            //rtt_result.Time_server = date_received
            //rtt_result.LenPayloadReaded = data.count
            //let data_string =  String(data: data, encoding: .utf8) ?? "null"
            //let rtt_time = Double(round( rtt_result.Time_server!.timeIntervalSince(rtt_result.Time_client!)*1000 )/1000)

            let rtt_time = rtt_result.Time_server - rtt_result.Time_client

            //let rtt_time = Double( rtt_result.Time_server!.timeIntervalSince(rtt_result.Time_client!))

            // let time_send = rtt_result.Time_client
            // let time_received = rtt_result.Time_server

            /* Time_send=\(time_send) Time_receive=\(time_received) */
            let now = TimeNow()
            print("\(now) id=\(rtt_result.Id)  RTT=\(rtt_time)us")
            //GUI?? SendData(timeReceive: uptime(), rtt: Double(rtt_time))

        } catch {
            print("Unexpected error: \(error).")
        }
    }

    //Conexión completada/finalizada
    if let complete = isComplete, complete == true {
        clientCLIConnectionEnded(error: error)
        return
    }

    //Error en la conexion
    if let error = error {
        clientCLIConnectionFailed(error: error)
        return
    }

    //Registrar de nuevo el handler
    //Establecer handle de recepción
    Task {
          if let qclient = await QPing.qclient {
              qclient.registerReceiveHandler(
                  minimumIncompleteLength: 1,
                  maximumLength: QPing.MTU,
                  completion: clientCLIHandleReceiveData
              )
          }
      }

}

/// CLIENT: Connection failed callback
@Sendable func clientCLIConnectionFailed(error: Error) {

    print("connection failed: " + error.localizedDescription)

    //Para loop
    Task { await QPing.setClientLoop(false) }
}

/// CLIENT: Connection ended callback
@Sendable func clientCLIConnectionEnded(error: Error?) {
    if error != nil {
        print("connection ended: " + error!.localizedDescription)
    } else {
        print("connection ended")
    }

    //Para loop
    Task { await QPing.setClientLoop(false) }
}

/// CLIENT: Send  callback.
@Sendable func clientCLISendCompleted(error: Error?) {
    if error != nil {
        print("Send error: " + error!.localizedDescription)
        
        //Para loop
        Task { await QPing.setClientLoop(false) }
    }
}


