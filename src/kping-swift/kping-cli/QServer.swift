//
//  main.swift
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
actor QServer{

    /// port de escucha
    let port: NWEndpoint.Port
    ///Set de seguimiento de conexiones activas
    var clientsConnections: Dictionary<UUID,ClientConnection> = [:]
    ///Listener de escucha
    private var listener: NWListener?
    ///networking queue
    private let networkQueue: DispatchQueue
    ///Estado del listener de escucha
    var state: NWListener.State {get{return listener!.state}}
    
    ///Number of  connection
    func clientsConnectionsNumber() -> Int  {
        return clientsConnections.count
    }
    
    ///Remove a clientConnection
    func removeClientConnection(id: UUID)
    {
             clientsConnections.removeValue(forKey: id)
    }
    
    ///Remove a clientConnection
    func addClientConnection(id: UUID, connection: ClientConnection)
    {
        clientsConnections[id] = connection
    }
 
    /// init
    init(port: UInt16) {
         //Listening port
        self.port = NWEndpoint.Port(rawValue: port)!
        
        //NetworkQueue
        networkQueue = DispatchQueue(label: "uno.kayros.networking")
    }
    
    /// Start listen. Don't block,
    func start(handleStateChanged:  @Sendable @escaping (NWListener.State) -> (), handleNewConnection:  @Sendable @escaping (NWConnection) -> ()) throws {
        //Parámetros de QUIC
        let quicOptions = NWProtocolQUIC.Options(alpn: ["kayros.uno"])
        quicOptions.direction = .bidirectional
        quicOptions.idleTimeout = QPing.CONNECTION_TIMEOUT
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
                    kSecAttrLabel:    "QPING",   //<<<< CERTIFICADO GUARDADO EN LLAVERO
            kSecReturnRef: true] as NSDictionary

        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        if status != errSecSuccess  {
            // handle error …
            print("\(TimeNow()) Error 66, certificado no encontrado")
        }
        let certificate = item as! SecCertificate
       
#if os(macOS)
    
        let identityStatus = SecIdentityCreateWithCertificate(nil, certificate, &identity)
        if identityStatus != errSecSuccess  {
            // handle error …
            print("\(TimeNow()) Error 73, certificado no creado")
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
        listener = try! NWListener(using: quicParameter, on: self.port)
      
        listener!.stateUpdateHandler = handleStateChanged
        listener!.newConnectionHandler = handleNewConnection
        listener!.start(queue: .main)
    }
    
    ///Conexión parada. Cambio de estado.
    private  func connectionStopped(_ connection: ClientConnection) {
         clientsConnections.removeValue(forKey: connection.id)
         print("\(TimeNow()) server did close connection \(connection.id)")
    }

    ///Stop qping server, and Stop all connection,
    func stop() {
        self.listener!.stateUpdateHandler = nil
        self.listener!.newConnectionHandler = nil
        self.listener!.cancel()
    }
}
