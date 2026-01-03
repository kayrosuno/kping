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


do {
    print("\(KPingState.Program) \(KPingState.Version)")
    if CommandLine.arguments.count < 2 {
        uso()
        exit(-1)
    }
        
    let firstArgument = CommandLine.arguments[1]
    switch (firstArgument) {
    case "server":  //Server mode
        
        if CommandLine.arguments.count > 2 {
            let qserver: () = try await QServer(port: UInt16(CommandLine.arguments[2])!).start()
        } else {
            let qserver: () = try await QServer(port: UInt16(String(KPingState.portDefault))!).start()
        }
            
    case "help", "-h":  //Help
        help()
            
    default:
        if CommandLine.arguments.count > 1 {
            let qclient: () = try await QClient(addr: CommandLine.arguments[1]).start()
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

/// Uso
func uso() {
    print("Use: kping <ipaddress:port>")
    print("Use: kping server <port>")
    print("Use: kping help | -h")
}

/// Help
func help() {

    print(
        "kping is a test program written in go and swift to verify the functionality and RTT delay of the QUIC Protocol"
    )
    print("")
    print("Use: kping <ipaddress:port>")
    print(
        "kping as a ping QUIC client. It requeries a kping Server to ping for, the client use the replies from the server to measure RTT time"
    )
    print("")
    print("Use: kping server <port>")
    print(
        "kping as a ping QUIC Server. kping act as a server listening for querys from the clients answering with a time mark to measure on the client the RTT "
    )
    print("")
    print("Use: kping help | -h")
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
    
