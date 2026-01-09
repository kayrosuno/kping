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
actor QClient {

    /// remote host
    private let host: NWEndpoint.Host
    /// remote port
    private let port: NWEndpoint.Port
    /// Networking queue for receive events
    private let networkQueue: DispatchQueue?
    /// Network connection using QUIC
    private(set) var nwConnection: NWConnection?
    /// kping internal state
    let kpingState: KPingState
    ///handleClientConnectionStateChanged, An external optional handle for GUI to notify change of state in the connection.
    private var handleClientConnectionStateChanged: (@Sendable (NWConnection.State) -> Void)?
    ///handleClientReceiveData, an external Handle optional for GUI interface to notify data received in the connection
    private var handleClientReceiveData: (@Sendable (Data?,NWConnection.ContentContext?,Bool,NWError?) -> Void)?
    ///Id iteration
    private(set) var iteration:Int64 = 0
    /// ClusterRunning (GUI)
    //private var clusterRunning: ClusterK8S?
    /// (GUI)
    private var isGUI: Bool
    
    ///Initialize the network connection, creacte DispatchQ //id
    //                var iteration: Int64 = 1ueue and nwConnection
    init(host: String, port: UInt16)
    {
        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(rawValue: port)!
               
        //NetworkQueue
        self.networkQueue = DispatchQueue(label: "uno.kayros.kping.server")
        
        self.kpingState = KPingState()
        self.isGUI = false
        
//        Task{
//            //await kpingState.setQClient(qclient: self)
//            self.clusterRunning = ClusterK8S()
//        }
    
    }
    
    //dummy init
    init()
    {
        self.host = NWEndpoint.Host("localhost")
        self.port = NWEndpoint.Port(rawValue: 0)!
        self.kpingState = KPingState()
        self.isGUI = false
        //NetworkQueue
        self.networkQueue = DispatchQueue(label: "uno.kayros.kping.server")
    }
    
    ///Initialize the network connection from GUI. Call it just after create the class.
//    func setClusterRunning(clusterRunning: ClusterK8S)
//    {
//        self.clusterRunning = clusterRunning
//        self.isGUI = true
//    }
    
    func setFlagGUI(isGUI: Bool)
    {
        self.isGUI = isGUI
    }
    
    /// Initialize class with string conataineing hosname and port  "hostname:port" throw error if ths string is mismatch.
    init(addr: String) throws
    {
        //Split addr en hostname and port
        let addr_split = addr.split(separator: ":")

        if addr_split.count < 2 {
            throw QError.invalidAddress(error: "invalid address: " + addr)
        }

        let hostname = String(addr_split[0])

        guard let port = UInt16(addr_split[1]) else {
            throw QError.invalidPort(error: "invalid port \(addr_split[1])")
        }
        
        self.init(host: hostname, port: port)
    }
  
    
    
    /// CLIENTLOOP: Run the Q in client mode, start a continuos loop running till finish the connection. Use var loop to false to exit from the loop.
    func start() async throws {

        print("kping 'start' client loop")

        //Parámetros de QUIC
        let quicOptions = NWProtocolQUIC.Options(alpn: ["kayros.uno"])
        quicOptions.direction = .bidirectional
        quicOptions.idleTimeout = KPingState.CONNECTION_TIMEOUT
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
            networkQueue!
        )
        let quicParameter = NWParameters(quic: quicOptions)

        //Network connection
        nwConnection = NWConnection(
            host: self.host,
            port: self.port,
            using: quicParameter
        )

        if (nwConnection == nil)
        {
            print("* Error creating NWConnection")
            exit(-1)
            
        }
        
        //handle de cambio de estado
        nwConnection!.stateUpdateHandler = handleClientConnectionStateChanged ?? self.clientCLIHandleConnectionStateChanged(to:)

        //Establecer la funcion de recepción
        nwConnection!.receive(
            minimumIncompleteLength: 10,
            maximumLength: KPingState.MTU,
            completion: handleClientReceiveData ?? self.clientCLIHandleReceiveData(_:_:_:_:) )
              
        //start Connection to remote server
        nwConnection?.start(queue: networkQueue!)

        //id
        var iteration:Int64 = 1
        
        //Bucle
        while await kpingState.clientLoop {
            //Check network state
            switch self.getConnectionState()
            {
            case .cancelled:
                print("\( TimeNow()) cancelled connection")
                break

            case .setup:
                print("\( TimeNow()) setup connection")

            case .waiting(_):
                print("\( TimeNow()) waiting connection, reconnecting")

            case .preparing:
                print("\( TimeNow()) preparing connection")

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

                let json_data: Data = try await MainActor.run {
                    let encoder = JSONEncoder()
                    encoder.dateEncodingStrategy = .millisecondsSince1970
                    return try encoder.encode(rtt_data)
                }
                
                //Send data to qping server
                nwConnection?.send(content: json_data, completion: .contentProcessed({ error in
                    if error != nil {
                        print("Send error: " + error!.localizedDescription)
                        
                        //Para loop
                        Task{ await self.kpingState.setClientLoop(false)}
                    }
                }
                ))

                iteration += 1

            case .failed(_):
                print("\( TimeNow()) connection failed")
                break

            @unknown default:
                print("\( TimeNow()) connection failed, unknow state")
            }
           
            if(isGUI)
            {
                //let uiState = UIState.shared
                //Espera delaySend ms
                try await Task.sleep(nanoseconds: UInt64(UIState.shared.clusterRunning.sendIntervalns))
            }
            else{
                //Espera delaySend ms
                try await Task.sleep(nanoseconds: KPingState.DELAY_1SEG_ns)
            }
        }
    }


    /// Stop internal nwConnection
    func stopConnection() {
        self.nwConnection?.stateUpdateHandler = nil
        self.nwConnection?.cancel()
    }
    
    ///Return state of the internal nwConnection
    func getConnectionState() -> NWConnection.State {
        return nwConnection!.state
    }

    ///Send data using internal nwConnection
    func send(data: Data, completion: @escaping @Sendable (NWError?) -> Void)
    {
        //TODO: Check state
        nwConnection?.send(
            content: data,
            completion: .contentProcessed(completion)
        )
    }

    /// Register  handler for data handler reception, call the handle when data received
    func registerReceiveHandler(
        minimumIncompleteLength: Int,
        maximumLength: Int,
        completion: @escaping @Sendable (_ content: Data?, _ contentContext: NWConnection.ContentContext?, _ isComplete: Bool, _ error: NWError?) -> Void)
    {
        self.nwConnection?.receive(
            minimumIncompleteLength: minimumIncompleteLength,
            maximumLength: maximumLength,
            completion: completion
        )
    }
    
    /// Set external handle for state changed
    func SetClientHandleConnectionStateChanged(handleClientConnectionStateChanged: @escaping @Sendable (NWConnection.State) -> Void)
    {
        self.handleClientConnectionStateChanged = handleClientConnectionStateChanged
    }
    
    /// Set external handle for receive data
    func SetClientHandleClientReceiveData(handleClientReceiveData: @escaping @Sendable (Data?,NWConnection.ContentContext?,Bool,NWError?) -> Void)
    {
        self.handleClientReceiveData = handleClientReceiveData
    }

    
    ///CLIENTE CLI: Handle estado conexion
    func clientCLIHandleConnectionStateChanged(to state: NWConnection.State) {
        switch state {
        case .waiting(_):
            //connectionFailed(error: error)
            print("* Client connection state changed to WAITING state")
        case .failed(let error):
            print("* Client connection state changed to FAILED state" + error.localizedDescription)
            
            //Para loop
            Task { await kpingState.setClientLoop(false) }

        default:
            break
        }
    }

    ///CLIENTE: Handle receive Data
    func clientCLIHandleReceiveData(
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
            if error != nil {
                print("connection ended: " + error!.localizedDescription)
            } else {
                print("connection ended")
            }

            //Para loop
            Task { await kpingState.setClientLoop(false) }
            return
        }

        //Error en la conexion
        if let error = error {
            print("connection failed: " + error.localizedDescription)

            //Para loop
            Task { await kpingState.setClientLoop(false) }
            return
        }

        //Registrar de nuevo el handler
        //Establecer handle de recepción
        nwConnection?.receive(
            minimumIncompleteLength: 1,
            maximumLength: KPingState.MTU,
            completion: handleClientReceiveData ?? self.clientCLIHandleReceiveData(_:_:_:_:)
        )
    }

    //////////////// GUI FUNCTIONS ///////////////////
    
    // MARK: stopQClient
    /// Para cliente QPing
//    @MainActor
//    func stopQClientGUI() async
//    {
//        if let c = appData.qclient{
//            await c.stopConnection()
//        }
//    }

    // MARK: runQClient
    /// Loop para espera de comando start y para ejecucion de qping en loop
    @MainActor
    func startQClientGUI(cluster: ClusterK8S)  async throws -> Void {
        
        //if appData ?? { print("QClientGUI: Error cluster not found.") ; return }
//        let cluster = appData.clusterRunning  //Do all activity with the cluster running
//        
//        guard let cluster else { print("QClientGUI: Error cluster not found.") ; return }
        
        if cluster.clusterData.nodes[cluster.clusterData.nodeSelected] == "" {
            cluster.kpingDataString.append(
                RTTData(
                    string: "Error: No node address found.\n",
                    id: 0,
                    timeReceived: uptime(),
                    delay: 0.0
                )
            )
            return
        }

        cluster.kpingDataString.append(
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
                  self.clientGUIHandleConnectionStateChanged(to: state)
              }
          })

          await qclient.SetClientHandleClientReceiveData(handleClientReceiveData: { content, contentContext, isComplete, error in
              Task { @MainActor in
                  self.clientGUIHandleReceiveData(content, contentContext, isComplete, error)
              }
          })
        
    //    await qclient.SetClientHandleConnectionStateChanged(handleClientConnectionStateChanged: clientGUIHandleConnectionStateChanged)
    //
    //    await qclient.SetClientHandleClientReceiveData(handleClientReceiveData: clientGUIHandleReceiveData)
        

        // Set qping client
        // appData.qclient = qclient
        
        //Delay between sends and reset all states and counters
        //cluster.delayms = appData.sendIntervalns
        cluster.resetCounter()
        cluster.estadoCluster = "Running"
        cluster.startTime = uptime()
        //await appData.qclient!.kping!.setClientLoop(true)
        
        //Connect
        try await qclient.start()
        
//        //Run qClient
//        Task {
//            do {
//                //Connect
//                try await qclient.start()
//
//                //id
//                var iteration: Int64 = 1
//
//                //Bucle
//                while await appData.qclient!.kping!.clientLoop {
//                    //Check network state
//                    switch await qclient.getConnectionState()
//                    {
//                    case .cancelled:
//                        printGUI("\(TimeNow()) cancelled connection")
//                        break
//
//                    case .setup:
//                        printGUI("\(TimeNow()) setup connection")
//
//                    case .waiting(_):
//                        printGUI("\(TimeNow()) waiting connection, reconnecting")
//
//                    case .preparing:
//                        printGUI("\(TimeNow()) preparing connection")
//
//                    case .ready:
//                        //Fill rtt
//                        let rtt_data = RTTQUIC(
//                            Id: iteration,
//                            Time_client: Int(
//                                Date().timeIntervalSince1970 * 1000 * 1000
//                            ),
//                            Time_server: 0,
//                            Data: KPingState.mensaje_data!
//                        )
//
//                        let encoder = JSONEncoder()
//                        encoder.dateEncodingStrategy = .millisecondsSince1970
//
//                        let json_data = try encoder.encode(rtt_data)
//
//                        iteration += 1
//
//                    case .failed(_):
//                        printGUI("\(TimeNow()) connection failed")
//                        break
//
//                    @unknown default:
//                        printGUI("\(TimeNow()) connection failed, unknow state")
//                    }
//
//                    //Espera delaySend ms
//                    try await Task.sleep(nanoseconds: UInt64(appData.sendIntervalns))
//                }
//
//            } catch {
//                if error is CancellationError {
//                    throw error
//                } else {
//                    throw error
//                }
//            }
        }
    

    //MARK: clientGUIHandleConnectionStateChanged
    /// CLIENTE GUI: Handle connections state changed
    @MainActor
    func clientGUIHandleConnectionStateChanged(to state: NWConnection.State)  -> Void  {
        switch state {
        case .waiting(_):
            printGUI("\(TimeNow())* Client connection state changed to WAITING state")
        case .failed(let error):
            printGUI("\(TimeNow())* Client connection state changed to FAILED state")
            clientGUIConnectionFailed(error: error)
        case .ready:
//            let rtt_data = RTTQUIC(
//                Id: iteration,
//                Time_client: Int(
//                    Date().timeIntervalSince1970 * 1000 * 1000
//                ),
//                Time_server: 0,
//                Data: KPingState.mensaje_data!
//            )
//
//            let encoder = JSONEncoder()
//            encoder.dateEncodingStrategy = .millisecondsSince1970
//
//            let json_data = try encoder.encode(rtt_data)
//
//            iteration += 1
            printGUI("\(TimeNow())* Client connection state changed to READY state")
        case .setup:
            printGUI("\(TimeNow())* Client connection state changed to SETUP state")
        case .preparing:
            printGUI("\(TimeNow())* Client connection state changed to SETUP state")
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

        let uiState = UIState.shared
        
        //    guard let kpingAppData = kpingAppData else {  print("\(TimeNow())clientGUIHandleReceiveData: Error no kpingAppData"); return }
        //
        let cluster = uiState.clusterRunning
        
        if cluster.id == ClusterK8S.idINVALID {
            print(
                "\(TimeNow())clientGUIHandleReceiveData: Error no cluster running"
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
                uiState.actualRTTns = rtt_time
                
                //Visualizar el rtt
                uiState.actualRTTns = rtt_time
                if rtt_time > uiState.maxRTTns { uiState.maxRTTns = rtt_time }
                if rtt_time < uiState.minRTTns || uiState.minRTTns == 0 { uiState.minRTTns = rtt_time }
               
                //Media rtt
                let nuevaCantidadNumeros = Double (cluster.kpingDataChart.count + 1)
                uiState.medRTTns = uiState.medRTTns == 0 ? rtt_time :
                ((uiState.medRTTns * Double(cluster.kpingDataChart.count)) + rtt_time) / nuevaCantidadNumeros
                
                //Actualizar datos del chart
                cluster.kpingDataChart.append(
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
        Task { await self.registerReceiveHandler(
            minimumIncompleteLength: 1,
            maximumLength: KPingState.MTU,
            completion:
                {
                    (content, contentContext, isComplete , error) in
                    Task { @MainActor in
                        self.clientGUIHandleReceiveData(content, contentContext, isComplete , error)
                    }
                }
            )
        }
    }


    ///GENERAL:  function to print  to GUI
    @MainActor
    func printGUI(_ cadena: String) {
       
        let uiState = UIState.shared
        
        Task {
           
            if uiState.clusterRunning.id == ClusterK8S.idINVALID  {  print("PrintGUI: Error no cluster running"); return }

            await uiState.clusterRunning.kpingDataString.append(
            RTTData(
                string: cadena,
                id: (kpingState.print_id),
                timeReceived: uptime(),
                delay: 0.0
            )
        )
        await kpingState.incPrintId()
        //Update timestamp for GUI
        // await kpingAppData.qclient?.kping!.kpingAppData?.setTimeStamp(timestamp: TimeNow())
            
        }
    }


    /// CLIENT: Connection failed callback
    @MainActor
    func clientGUIConnectionFailed(error: Error) {
        //let uiState = UIState.shared
        printGUI("connection failed: " + error.localizedDescription)

        //Para loop
        Task {
            await kpingState.setClientLoop(false)
        }
    }

    /// CLIENT: Connection ended callback
    @MainActor
    func clientGUIConnectionEnded(error: Error?) {
      
        if error != nil {
            printGUI("connection ended: " + error!.localizedDescription)
        } else {
            printGUI("connection ended")
        }

        //Para loop
        Task {
            await kpingState.setClientLoop(false)
        }
    }


//    /// CLIENT: Send  callback.
//    @MainActor
//    func clientGUISendCompleted(error: Error?) {
//      
//        if error != nil {
//            printGUI("Send error: " + error!.localizedDescription)
//            
//            //Para loop
//            Task {
//                await kpingState.setClientLoop(false)
//            }
//        }
//    }
    
}


