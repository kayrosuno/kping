# QPING

qping is a ping utility for the QUIC protocol
available in go and Swift. 

qping support RFC 9000
QUIC: A UDP-Based Multiplexed and Secure Transport

Available implementation in go and swift help to test 5G networks low latency using QUIC protocols, measure RTT, MTU and Bandwith. go implementations are suitable for use in machines running Linux or macOS while swift implementation is helpfull to do the test over iOS devices with 5G connectivity as well as macOS


## qping server mode
In "server" mode qping act as a server listening for QUIC connection. Open a new connection for each client and listen for the request, the server reply to each client request

Use: qping server <port>
Example: ./qping server 25450

Start a quic server to listen into the specified port, default port is 25450

Example: ./qping server

###  macOS - Swift
Developed version with Swift language using Apple library Network and NWProtocolQUIC. This version run over macOS 12.0+   
 
###  Linux - Go
Developed version with go language. This version use quicgo library. This version run over Linux servers.
 

## qping client mode
qping is a client written in go and swift to connect to a server using QUIC. 
The client send requests to the server and receive from the server answers to measure rtt.
You need a qping acting as server to reply to client requests.

Use: qping <ip_server>:<port>
Example: ./qping 192.168.2.70:30000

### macOS - Swift 
Developed version with Swift language using Apple library Network and NWProtocolQUIC. This version run over macOS 12.0+   

### iOS - Swift 
Developed version with Swift language using Apple library Network and NWProtocolQUIC. This version run over iOS 15+  
 
 
###  Linux - Go
Developed version with go language. This version use quicgo library. This version run over Linux servers.
 

###  Kubernetes test and deployment
Kubernetes deployment locatd in qping-kubernetes


## CA Certificate
You must change the CA certificate and use your own. You can follow this link to read whow to do it: https://developer.apple.com/documentation/network/creating_an_identity_for_local_network_tls


## #L4S
L4S
to decrease latency time, activate L4S in macOS or iOS

macos:
% sudo defaults write -g network_enable_l4s -bool true
% sudo defaults read network_enable_l4s 


iOS iphone:
Activade in settings --> Development --> L4S

Here you can find how to test L4S with apple devices
https://developer.apple.com/documentation/network/testing_and_debugging_l4s_in_your_app

