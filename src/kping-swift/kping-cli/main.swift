//
//  main.swift
//
//
//  Created by Alejandro Garcia on 16/5/23.
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


// Esto es Swift!!  Podemos comenzar desde el principio a escribir el programa!!
// Main
do {
    print("\(QPing.Program) \(QPing.Version)")
    if CommandLine.arguments.count < 2 {
        uso()
        exit(-1)
    }

    let firstArgument = CommandLine.arguments[1]
    switch (firstArgument) {
    case "server":  //Server mode
        if CommandLine.arguments.count > 2 {
            try await serverLoop(serverport: CommandLine.arguments[2])
        } else {
            try await serverLoop(serverport: String(QPing.portDefault))
        }

    case "help", "-h":  //Help
        help()

    default:
        if CommandLine.arguments.count > 1 {
            try await clientLoop(addr: CommandLine.arguments[1])
        } else {
            uso()
        }

    }
} catch QError.invalidAddress(let error) {
    print("**ERROR** >> \(error). Please enter a valid address.\n\n")
    uso()
    exit(-1)
} catch QError.invalidPort(let error) {
    print("**ERROR** >> \(error). Please enter a valid port number.\n\n")
    uso()
    exit(-1)
} catch {
    print("Unexpected error: \(error).\n\n")
    uso()
    exit(-1)
}

/// Act as Server. Start the server loop, create a QServer to respond with time to measure rtt time
@MainActor
func serverLoop(serverport: String) async throws {

    print("\(TimeNow()) qping server loop")

    guard let port = UInt16(serverport) else {
        throw QError.invalidPort(
            error: "invalid port error: \(serverport) not valid"
        )
    }

    print("\(TimeNow()) Starting qping QUIC server on port: \(port)")

    // Iniciar QServer
    QPing.qserver = QServer(port: port)
    guard let qserver = QPing.qserver else {
        throw QError.generic(error: "Internal error creating qping server") //TODO: Especificar error. Throw?
    }
        
    try await qserver.start(
        handleStateChanged: handleServerStateChanged,
        handleNewConnection: handleNewConnectionInServer
    )

    while true {  //Server espera hasta la finalización, esto hay que hacerlo en bucle porque swift no bloquea las llamadas y no se gestiona con async, utiliza threads y handles con los cambios de estado o lectura de datos. Otra alternativa más tipo go??
        switch await qserver.state {
        case .ready:
            // RunLoop.current.run(until: .now + 30)  //segundos
            //Espera delaySend ms
            //try await Task.sleep( for: .milliseconds(QPing.delaySendms), tolerance: .seconds(30)           )
            try await Task.sleep(nanoseconds: QPing.DELAY_LOOP_SERVER_ns)
            
            //TODO: Chequear estado del listener
            await print(
                "\(TimeNow()) Server status: \(qserver.state) ; online clients: \(qserver.clientsConnectionsNumber())"
            )

        case .cancelled:
            //Server cancelled, exit
            await print(
                "\(TimeNow()) Server status: \(qserver.state) ; online clients: \(qserver.clientsConnectionsNumber())"
            )
            exit(0)

        case .failed:
            //Server cancelled, exit
            await print(
                "\(TimeNow()) Server status: \(qserver.state) ; online clients: \(qserver.clientsConnectionsNumber())"
            )
            exit(-1)

        default:
            try await Task.sleep(nanoseconds: QPing.DELAY_1SEG_ns)  //nanosegundos

        }
    }
}


/// CLIENTLOOP: Run the Q in client mode, start a continuos loop running till finish the connection. Use var loop to false to exit from the loop.
// @Sendable
@MainActor
func clientLoop(addr: String) async throws {

    print("qping client loop")

    //Split addr en hostname and port
    let addr_split = addr.split(separator: ":")

    if addr_split.count < 2 {
        throw QError.invalidAddress(error: "invalid address: " + addr)
    }

    let hostname = String(addr_split[0])

    guard let port = UInt16(addr_split[1]) else {
        throw QError.invalidPort(error: "invalid port \(addr_split[1])")
    }

    //Cliente qping
    QPing.qclient = QClient(
        host: hostname,
        port: port,
        handleClientConnectionStateChanged: clientCLIHandleConnectionStateChanged,
        handleClientReceiveData: clientCLIHandleReceiveData
    )
    //TODO: <<<>>> gestionar estado
    guard let qclient = QPing.qclient else {
        throw QError.generic(error: "Internal error creating qping client")  //TODO: Especificar error. throw?
    }

    //Connect
    qclient.startConnection()

    //id
    var iteration:Int64 = 1
    
    //Bucle
    while QPing.clientLoop {
        //Check network state
        switch qclient.getConnectionState()
        {
        case .cancelled:
            print("\(TimeNow()) cancelled connection")
            break

        case .setup:
            print("\(TimeNow()) setup connection")

        case .waiting(_):
            print("\(TimeNow()) waiting connection, reconnecting")

        case .preparing:
            print("\(TimeNow()) preparing connection")

        case .ready:

            //Fill rtt
            let rtt_data = RTTQUIC(
                Id: iteration,
                Time_client: Int(
                    Date().timeIntervalSince1970 * 1000 * 1000
                ),
                Time_server: 0,
                Data: QPing.mensaje_data!
            )

            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .millisecondsSince1970

            let json_data = try encoder.encode(rtt_data)
            
            //Send data to qping server
            qclient.send(
                data: json_data,
                completion: clientCLISendCompleted
            )

            iteration += 1

        case .failed(_):
            print("\(TimeNow()) connection failed")
            break

        @unknown default:
            print("\(TimeNow()) connection failed, unknow state")
        }

        //Espera delaySend ms
        try await Task.sleep(nanoseconds: QPing.DELAY_1SEG_ns)
    }

}

/// SERVER: Handle for server state changed
func handleServerStateChanged(to newState: NWListener.State) {
    switch newState {
    case .ready:
        print(
            TimeNow()
                + " Server status changed to READY. Waiting for qping clients connections..."
        )

    case .failed(let error):
        print(
            TimeNow() + " Server status changed to FAILED, error: \(error.localizedDescription)"
        )
        exit(EXIT_FAILURE)

    case .setup:
        print(TimeNow() + " Server status changed to SETUP...")

    case .cancelled:
        print(TimeNow() + " Server status changed to CANCELLED")

    case .waiting(let error):
        print(
            TimeNow() + "Server status changed to WAITING, error: \(error.localizedDescription)"
        )

    default:
        break
    }
}

///SERVER: Handle for new connection
func handleNewConnectionInServer(_ nwConnection: NWConnection) {

    guard let qserver = QPing.qserver else {
        //throw QError.generic(error: "Internal error creating qping server") //TODO: Especificar error. Throw?
        print("Internal error 290.")
        exit(-1)
    }
    
    let connection = ClientConnection(
        qServer: qserver,
        id: UUID(),
        nwConnection: nwConnection
    )
    Task{ //Para acceder a un conexto distinto.
        await qserver.addClientConnection(id: connection.id , connection: connection)
    }
    
    connection.AcceptStream()  //Acepta la conexión
}

/// Uso
func uso() {
    print("Use: qping <ipaddress:port>")
    print("Use: qping server <port>")
    print("Use: qping help | -h")
}

/// Help
func help() {

    print(
        "qping is a test program written in go and swift to verify the functionality and RTT delay of the QUIC Protocol"
    )
    print("")
    print("Use: qping <ipaddress:port>")
    print(
        "qping as a ping QUIC client. It requeries a qping Server to ping for, the client use the replies from the server to measure RTT time"
    )
    print("")
    print("Use: qping server <port>")
    print(
        "qping as a ping QUIC Server. qping act as a server listening for querys from the clients answering with a time mark to measure on the client the RTT "
    )
    print("")
    print("Use: qping help | -h")
    print("This help")
}

#if os(macOS)
    ///Secure identity
    func getSecIdentity() -> SecIdentity? {
        
        var identity: SecIdentity?
        let getquery = [kSecClass: kSecClassCertificate,
                    kSecAttrLabel: "Apple Development: MANUEL ALEJANDRO GARCIA DOMINGUEZ (A3F723B3BA)",
                    kSecReturnRef: true] as NSDictionary
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        guard status == errSecSuccess else {
            // handle error …
            return identity
        }
        let certificate = item as! SecCertificate
        
        let identityStatus = SecIdentityCreateWithCertificate(nil, certificate, &identity)
        guard identityStatus == errSecSuccess else {
            // handle error …
            return identity
        }
        
        return identity
    }
#endif
    
