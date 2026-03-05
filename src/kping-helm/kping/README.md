# KPING
kqping is an utility to test networking communications in kubernetes cluster.

kping has been developed using go for linux platforms and Swift for macOS/iOS/Linux

kping can test communications launching the program as server mode or using the program as client mode.
The program can run as [standalone](https://github.com/kayrosuno/kping/releases) on linux (x86/arm) and macOS, [docker image](https://hub.docker.com/repository/docker/kayrosuno/kping/general) or [helm chart](https://artifacthub.io/packages/helm/kping/kping). For macOS and iOS GUI you must compile the app using xcode and install locally.

kping can work with the following protocols:
- UDP
- QUIC
- TCP
- SCTP

Available implementation in go and swift help to test 5G networks low latency using QUIC protocols, measure RTT. go implementations are suitable for use in machines running Linux or macOS while swift implementation is helpful to do the test over iOS devices with 5G connectivity as well as macOS
You can find more information at https://kayros.uno

