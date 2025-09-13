//
//  ClientConnection.swift
//  qserver
//
//  Created by Alejandro Garcia on 17/5/23.
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

/// Conexion al server. Lee los datos enviado por qping en modo cliente. (QClient)
@available(macOS 10.14, *)

final class ClientConnection: Sendable {
    
    /// QServer padre asociado esta conexión
    private let qserver: QServer
    /// id interno de conexión
    let id: UUID
    /// NWConnection encapsulada
    private let nwConnection: NWConnection
    /// RTT struct
    //private var rtt: RTTQUIC! = RTTQUIC()
    /// JSONDecoder
    private let decoder = JSONDecoder()
    /// JSONEncoder
    private let encoder = JSONEncoder()
    
    ///Init desde NWListener
    init(qServer: QServer, id: UUID, nwConnection: NWConnection) {
        self.nwConnection = nwConnection
        self.id = id
        self.qserver = qServer
        printDEBUG("\(TimeNow())client connection created \(id)")
    }
    
    ///Iniciar aceptacion de conexiones
    func AcceptStream() {
        
        //handle de cambio de estado
        nwConnection.stateUpdateHandler = handleClientConnectionStateChanged
        
        //Establecer handle de recepción
        nwConnection.receive(minimumIncompleteLength: 1,
                             maximumLength: QPing.MTU,
                             completion: handleClientConnectionReceiveData)
        
        //Iniciar cola de recepción
        nwConnection.start(queue: .main)
    }
    
    
    //TODO: sanity check de conexiones, no se eliminan de la tupla de conexiones
    
    ///Handle Cambio estado conexion
    func handleClientConnectionStateChanged(to state: NWConnection.State) {
        switch state {
        case .waiting(let error):
            print("client connection \(id) waiting "+error.localizedDescription)
            //          qServer.connectionsByID.removeValue(forKey: id)
        case .ready:
            print("client connection \(id) ready")
        case .failed(let error):
            handleClientConnectionFailed(error: error)
            //          qServer.connectionsByID.removeValue(forKey: id)
        default:
            break
        }
    }
    
    
    ///Handle for Receive Data
    ///(_ content: Data?, _ contentContext: NWConnection.ContentContext?, _ isComplete: Bool, _ error: NWError?)
    func handleClientConnectionReceiveData(_ content: Data?, _ contentContext: NWConnection.ContentContext?, _ isComplete: Bool?, _ error: NWError?) {
        
        //Procesar datos recibidos de la conexión
        if let data = content, !data.isEmpty {
            do
            {
                let date_received = Date()
                
                decoder.dateDecodingStrategy = .millisecondsSince1970
                var rtt_result = try decoder.decode(RTTQUIC.self, from: data)
                
                rtt_result.Time_server = Int (date_received.timeIntervalSince1970 * 1000 * 1000)
                rtt_result.LenPayloadReaded = data.count
                   
                // Send reply
                encoder.dateEncodingStrategy = .millisecondsSince1970
                let reply_data = try encoder.encode(rtt_result)
                self.send(data: reply_data)
                        
            } catch {
                print("\(TimeNow()) handleClientConnectionReceiveData Unexpected error: \(error).")
            }
        }
        
        //Conexión completada/finalizada
        if let complete = isComplete, complete==true {
            //self.connectionEnded()
            print("\(TimeNow()) client connection \(self.id) completed")
            return;
        }
        
        //Error en la conexion
        if let error = error {
            self.handleClientConnectionFailed(error: error)
            return; //Salimos
        }
        
        
        
        //Registrar de nuevo el handler
        //Establecer handle de recepción
        nwConnection.receive(minimumIncompleteLength: 1,
                             maximumLength: QPing.MTU,
                             completion: handleClientConnectionReceiveData)
        
    }
    
    ///Send data
    func send(data: Data) {
        self.nwConnection.send(content: data, completion: .contentProcessed( { error in
            if let error = error {
                // closeClientConnection(error: error)
                print("Send error \(error)")
            }
            //print("connection \(self.id) did send, data: \(data as NSData)")
        }))
    }
    
    ///Callback conexion fallida
    private func handleClientConnectionFailed(error: Error) {
        print("\(TimeNow()) client connection \(id) did fail, error: \(error)")
        closeClientConnection(error: error)
    }

    ///Callback conexion finalizada
    private func handleClientConnectionEnded() {
        print("\(TimeNow()) client connection \(id) did end")
        closeClientConnection(error: nil)
    }
    
    ///Parar conexion y eliminar de la lista de conexiones cliente del qping server
    private func closeClientConnection(error: Error?) {
        nwConnection.stateUpdateHandler = nil
        nwConnection.forceCancel()
        Task {
            await qserver.removeClientConnection(id: self.id)
        }
        
    }

}
