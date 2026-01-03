//
//  QServer.swift
//
//
//  Created by Alejandro Garcia on 15/5/23.
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


///Clase QServer. Escucha por conexiones QUIC.
@available(macOS 12, *)
@available(iOS 15, *)
actor QServer {

    /// port de escucha
    let port: NWEndpoint.Port
    ///Set de seguimiento de conexiones activas
    private(set) var dicClientsConnections: Dictionary<UUID,QServerClientConnection> = [:]
    ///Listener de escucha
    private(set) var listener: NWListener?
    ///networking queue
    private let networkQueue: DispatchQueue
    ///Estado del listener de escucha (read only var)
    var state: NWListener.State {get{return listener!.state}}
    
    // kping
    private let kping: KPingState?
    
    /// init
    init(port: UInt16) {
        
        //Listening port
        self.port = NWEndpoint.Port(rawValue: port)!
        
        //NetworkQueue
        networkQueue = DispatchQueue(label: "uno.kayros.kping.client")
        
        self.kping = KPingState()
        Task{ await self.kping?.setQServer(qserver: self) }
    }
       
    
    ///Number of  connection
    func clientsConnectionsNumber() -> Int  {
        return dicClientsConnections.count
    }
    
    ///Remove a clientConnection
    func removeClientConnection(id: UUID)
    {
        dicClientsConnections.removeValue(forKey: id)
    }
    
    ///Remove a clientConnection
    func addClientConnection(connection: QServerClientConnection)
    {
        dicClientsConnections[connection.id] = connection
    }
 

    
    /// Start server to listen. Don't block,
    func start() async throws {
        
        print("\( TimeNow()) kping 'start' server loop")

        print("\( TimeNow()) Starting kping QUIC server on port: \(self.port)")
        
        //Parámetros de QUIC
        let quicOptions = NWProtocolQUIC.Options(alpn: ["kayros.uno"])
        quicOptions.direction = .bidirectional
        quicOptions.idleTimeout = KPingState.CONNECTION_TIMEOUT
        let securityProtocolOptions: sec_protocol_options_t = quicOptions.securityProtocolOptions
        sec_protocol_options_set_verify_block(securityProtocolOptions,
                                              { (_: sec_protocol_metadata_t,
                                                 _: sec_trust_t,
                                                 complete: @escaping sec_protocol_verify_complete_t) in
            complete(true)
        }, networkQueue)
        
        //CA
        var identity: SecIdentity?
        let getquery = [kSecClass: kSecClassCertificate,
            //kSecAttrLabel: "Apple Development: MANUEL ALEJANDRO GARCIA DOMINGUEZ (A3F723B3BA)",
                    kSecAttrLabel:    "KPING",   //<<<< CERTIFICADO GUARDADO EN LLAVERO
            kSecReturnRef: true] as NSDictionary

        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        if status != errSecSuccess  {
            // handle error …
            print("\( TimeNow()) Error 66, certificado no encontrado")
        }
        let certificate = item as! SecCertificate
       
#if os(macOS)
    
        let identityStatus = SecIdentityCreateWithCertificate(nil, certificate, &identity)
        if identityStatus != errSecSuccess  {
            // handle error …
            print("\( TimeNow()) Error 73, certificado no creado")
         }
   
        if let secIdentity = sec_identity_create(identity!) {
                sec_protocol_options_set_min_tls_protocol_version(
                    quicOptions.securityProtocolOptions, .TLSv12)
                sec_protocol_options_set_local_identity(
                    quicOptions.securityProtocolOptions, secIdentity)
        }
#endif
        // QUIC Parameters
        let quicParameter = NWParameters(quic: quicOptions)
  
        //Inicializa el listener con los parametros de options y el port
        listener = try NWListener(using: quicParameter, on: self.port)
        
        //Set handle change of state
        listener!.stateUpdateHandler = { newState in
                switch newState {
                case .ready:
                    print( TimeNow() + " Server status changed to READY. Waiting for qping clients connections..." )

                case .failed(let error):
                    print( TimeNow() + " Server status changed to FAILED, error: \(error.localizedDescription)"
                            
                    )
                    exit(EXIT_FAILURE)

                case .setup:
                    print( TimeNow() + " Server status changed to SETUP...")

                case .cancelled:
                    print(  TimeNow() + " Server status changed to CANCELLED")

                case .waiting(let error):
                    print( TimeNow() + "Server status changed to WAITING, error: \(error.localizedDescription)")

                default:
                    break
                }
        }
        
        //Set handle for new connections of clients
        listener!.newConnectionHandler = { [self]  connection in

                    let clientConnection =  QServerClientConnection(
                        qserver: self,
                        id: UUID(),
                        nwConnection: connection
                    )
            
                    Task {
                        
                        //Añade cliente al diccionario
                        await addClientConnection(connection: clientConnection)
                    
                        //Estable handles e inicia la cola
                        await clientConnection.start()
                        
                    }
        }
        
        listener!.start(queue: .main) //Inicia cola
        
        while true {  //Server espera hasta la finalización, esto hay que hacerlo en bucle porque swift no bloquea las llamadas y no se gestiona con async, utiliza threads y handles con los cambios de estado o lectura de datos. Otra alternativa más tipo go??
            switch self.state {
            case .ready:
                // RunLoop.current.run(until: .now + 30)  //segundos
                //Espera delaySend ms
                //try await Task.sleep( for: .milliseconds(QPing.delaySendms), tolerance: .seconds(30)           )
                try await Task.sleep(nanoseconds: KPingState.DELAY_LOOP_SERVER_ns)
                
                //TODO: Chequear estado del listener
                print(
                    "\( TimeNow()) Server status: \(self.state) ; online clients: \(self.clientsConnectionsNumber())"
                )

            case .cancelled:
                //Server cancelled, exit
                print(
                    "\( TimeNow()) Server status: \(self.state) ; online clients: \(self.clientsConnectionsNumber())"
                )
                exit(0)

            case .failed:
                //Server cancelled, exit
                print(
                    "\( TimeNow()) Server status: \(self.state) ; online clients: \(self.clientsConnectionsNumber())"
                )
                exit(-1)

            default:
                try await Task.sleep(nanoseconds: KPingState.DELAY_1SEG_ns)  //nanosegundos

            }
        }
    }
    
    
//    ///Conexión parada. Cambio de estado.
//    private  func connectionStopped(_ connection: ClientConnection) {
//         clientsConnections.removeValue(forKey: connection.id)
//         print("\(TimeNow()) server did close connection \(connection.id)")
//    }

//    ///Stop qping server, and Stop all connection,
//    func stop() {
//        self.listener!.stateUpdateHandler = nil
//        self.listener!.newConnectionHandler = nil
//        self.listener!.cancel()
//    }
}

