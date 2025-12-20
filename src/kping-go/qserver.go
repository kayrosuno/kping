/*
Copyright © 2023-2025 Alejandro Garcia <iacobus75@gmail.com>  <alejandro@kayros.uno>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// Package qgoserver implements a server for echoing data and rtt measure using QUIC protocols
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net"
	"os"
	"strconv"
	"sync"
	"time"

	"github.com/quic-go/quic-go" //REDIS
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

// Start a server that echos all data for each stream opened by the client
func qserver(args []string) error {

	var port = sPortDefault
	//var addr = "0.0.0.0:"
	//var rtt RTTQUIC
	var wg sync.WaitGroup

	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr, TimeFormat: time.RFC3339})

	log.Info().Str(Program, Version).Msg("kping server mode")

	//Check port
	if len(args) > 0 {

		_, err := strconv.Atoi(args[0])
		if err != nil {
			log.Error().Msg("incorrect argument port " + err.Error())
			port = sPortDefault
		}
		//addr += args[0]
		port = args[0]
	}
	//else {
	//	addr += sPortDefault
	//}

	var iPort, err = strconv.Atoi(port)
	if err != nil {
		log.Error().Msg("incorrect argument port " + err.Error())
		iPort = iPortDefault
	}

	//TODO, check IPV4 or IPv6
	//var Udp4Conn *net.UDPConn
	//if net.IP.To4(net.IP) != nil {

	// IPv4 ////////////////////////////////

	// UDP-QUIC ipv4 ////////////////////////////
	// Udp4Conn, err := net.ListenUDP("udp4", &net.UDPAddr{Port: iPort})
	// 1.- UDP
	Udp4Conn, err := net.ListenPacket("udp4", ":"+strconv.Itoa(iPort))
	if err != nil {
		log.Error().Msg(fmt.Sprintf("Error %s", err.Error()))
		return err
	}
	// 2.- Transport
	tr := quic.Transport{
		Conn: Udp4Conn,
	}
	quicConf := quic.Config{}
	// 3.- Listen
	listenerQuic4, err := tr.Listen(GenerateTLSConfig(), &quicConf)
	if err != nil {
		log.Error().Msg(fmt.Sprintf("Error %s", err.Error()))
		return err
	}
	log.Info().Msg(fmt.Sprintf("Starting ping IPv4-QUIC/UDP server on port %s", listenerQuic4.Addr().String()))

	// IPv6 /////////////////////////////////////
	// UDP+QUIC ipv6 ////////////////////////////
	// 1.- UDP
	Udp6Conn, err6 := net.ListenUDP("udp6", &net.UDPAddr{Port: iPort})
	if err6 != nil {
		log.Error().Msg(fmt.Sprintf("Error %s", err6.Error()))
		return err6
	}
	// 2.- Transport
	tr6 := quic.Transport{
		Conn: Udp6Conn,
	}
	quicConf6 := quic.Config{}
	// 3.- Listen
	listenerQuic6, err6 := tr6.Listen(GenerateTLSConfig(), &quicConf6)
	if err6 != nil {
		log.Error().Msg(fmt.Sprintf("Error %s", err6.Error()))
		return err6
	}
	log.Info().Msg(fmt.Sprintf("Starting ping IPv6-QUIC/UDP server on port %s", listenerQuic6.Addr().String()))

	// IPv4 ////////////////////////////
	// TCP4 ////////////////////////////
	// 1.- Listen TCP
	listenerTCP4, errTCP := net.Listen("tcp4", "0.0.0.0:"+strconv.Itoa(iPort))
	if errTCP != nil {
		log.Error().Msg(fmt.Sprintf("Error %s", errTCP.Error()))
		return errTCP
	}
	log.Info().Msg(fmt.Sprintf("Starting ping IPv4-TCP server on port %s", listenerTCP4.Addr().String()))

	wg.Add(4)

	//Listen IPv4. QUIC
	go listenIPv4QUIC(listenerQuic4, &wg)

	//Listen IPv6. QUIC
	go listenIPv6QUIC(listenerQuic6, &wg)

	//Listen UDP4
	go listenIPv4UDP(iPort, &wg)

	//Listen TCP4
	go listenIPv4TCP(listenerTCP4, &wg)

	wg.Wait()

	return err //ipv4
}

// Nueva conexión aceptada
func listenIPv4UDP(iPort int, wg *sync.WaitGroup) {
	defer wg.Done()

	//NOTA: Use port+1 to permit listen QUIC/UDP on trraget port and targetport+1 for UDP without QUIC

	log.Info().Msg(fmt.Sprintf("Starting ping IPv4-UDP server on port %d", iPort+1))
	//for { //TODO check SIGTERM
	// UDP  ///////////////////////////////
	// 1. Resolver la dirección UDP
	addr, err := net.ResolveUDPAddr("udp", ":"+strconv.Itoa(iPort+1))
	if err != nil {

		log.Fatal().Msg(fmt.Sprintf("No se pudo resolver la dirección: %v", err))
	}

	// Espera conexiones UDP
	udpConn, err := net.ListenUDP("udp4", addr)
	if err != nil {
		log.Error().Msg(fmt.Sprintf("Error %s", err.Error()))

	} else {
		defer udpConn.Close()         // 5. Cerrar el socket al final
		handleUDP4Connection(udpConn) //Nueva conexión de cliente
	}

	//}
}

// Nueva conexión aceptada
func listenIPv4QUIC(listener *quic.Listener, wg *sync.WaitGroup) {
	defer wg.Done()
	for { //TODO check SIGTERM
		//log.Info().Msg("*****  listenIPv4QUIC")
		//Escucha en el puerto indicado, y bloquea a la espera
		conn, err := listener.Accept(context.Background()) //Escuchar por nuevas conexiones
		if err != nil {
			log.Error().Msg(fmt.Sprintf("Error with new connection: %s", err.Error()))
			continue
		}

		go handleQUICConnection(conn) //Nueva conexión de cliente

	}
}

// Nueva conexión aceptada
func listenIPv6QUIC(listener6 *quic.Listener, wg *sync.WaitGroup) {
	defer wg.Done()
	for {
		//Escucha en el puerto indicado, y bloquea a la espera
		conn6, err6 := listener6.Accept(context.Background()) //Escuchar por nuevas conexiones
		if err6 != nil {
			log.Error().Msg(fmt.Sprintf("Error with new connection: %s", err6.Error()))
			continue
		}

		go handleQUICConnection(conn6) //Nueva conexión de cliente
	}
}

// Aceptar conexiones TCP
func listenIPv4TCP(listener net.Listener, wg *sync.WaitGroup) {
	defer wg.Done()
	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Error().Msg(fmt.Sprintf("Error with new connection: %s", err.Error()))
			continue
		}
		go handleTCPConnection(conn)
	}
}

// Nueva conexion UDP aceptada
func handleUDP4Connection(conn *net.UDPConn) {

	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr, TimeFormat: time.RFC3339})

	// Echo local for data send by client
	for {
		//
		//Leer los datos
		//----------------------------
		//
		buf := make([]byte, maxMessage)

		bytesReaded, remoteAddr, err := conn.ReadFromUDP(buf)

		log.Info().Msg(fmt.Sprintf("New UDP packet <-- client from %s", remoteAddr.String()))

		if err != nil {
			if err != io.EOF {
				//Log error
				log.Error().Msg(fmt.Sprintf("Client %s '%s'", remoteAddr.String(), err.Error()))
				continue
			}
		}

		//Unmarshalling JSON
		var rtt RTTQUIC

		if err := json.Unmarshal(buf[:bytesReaded], &rtt); err != nil { //El unmarshal se lee de un slice con los datos leidos, no mas para evitar datos erroneos
			log.Error().Msg(fmt.Sprintf("Error unmarshalling json data: %s", err.Error()))
			continue
		}

		rtt.Time_server = time.Now().UnixMicro()
		rtt.LenPayloadReaded = len(rtt.Data)

		//log.Info().Msg(fmt.Sprintf("<<<: %s Got '%s'", conn.RemoteAddr().String(), string(buf)))

		//
		//Escribir respuesta al cliente
		//----------------------------
		//

		//marshall json
		data, err := json.Marshal(rtt)
		if err != nil {
			//Log error
			log.Error().Msg(fmt.Sprintf("Json marshall failed '%s'", err.Error()))
			continue
		}
		//
		//Enviar data json
		//
		_, err = conn.WriteToUDP(data, remoteAddr)
		if err != nil {
			//Log error
			log.Error().Msg(fmt.Sprintf("Error '%s'", err.Error()))
			continue
		}

		//Int64("t_marshall", time_marshall).Int64("t_send", time_send).
		//log.Info().Msg(fmt.Sprintf("-> '%s' mesg: '%s'", conn.RemoteAddr().String(), data))

	}

	//Log error
	log.Info().Msg(fmt.Sprintf("END listening UDP data"))

}

// Nueva conexión QUIC aceptada
func handleQUICConnection(conn *quic.Conn) {

	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr, TimeFormat: time.RFC3339})

	log.Info().Msg(fmt.Sprintf("New QUIC/UDP connection <-- client from %s", conn.RemoteAddr().String()))

	// TODO: conseguir la dirección IP o DNS del servidor redis asociado

	// Connecty to redis server
	// clientRedis := redis.NewClient(&redis.Options{
	// 	Addr:     "127.0.0.1:6379",
	// 	Password: "", // no password set
	// 	DB:       0,  // use default DB
	// })

	// ctx := context.Background()

	// err := clientRedis.Set(ctx, "Cliente XX", "ping xx ms", 0).Err()
	// if err != nil {
	// 	//panic(err)
	// 	log.Error().Msg(fmt.Sprintf("Error redis server: %s", err.Error()))
	// }

	// val, err := clientRedis.Get(ctx, "Cliente XX").Result()
	// if err != nil {
	// 	//panic(err)
	// 	log.Error().Msg(fmt.Sprintf("Error redis server: %s", err.Error()))
	// } else {
	// 	//fmt.Println("foo", val)
	// 	log.Info().Msg(fmt.Sprintf("Valor de prueba cliente XX: %s", val))
	// }

	stream, err := conn.AcceptStream(context.Background())
	if err != nil {
		log.Error().Msg(fmt.Sprintf("Error accepting new stream: %s", err.Error()))
		return
		//panic(err)
	}

	//Cerrar diferido
	defer stream.Close()

	// Echo local for data send by client
	for {
		//
		//Leer los datos
		//----------------------------
		//
		buf := make([]byte, maxMessage)
		bytesReaded, err := io.ReadAtLeast(stream, buf, 20)
		if err != nil {
			if err != io.EOF {
				//Log error
				log.Error().Msg(fmt.Sprintf("Client %s '%s'", conn.RemoteAddr().String(), err.Error()))
				break
			}
		}

		//Unmarshalling JSON
		var rtt RTTQUIC

		if err := json.Unmarshal(buf[:bytesReaded], &rtt); err != nil { //El unmarshal se lee de un slice con los datos leidos, no mas para evitar datos erroneos
			log.Error().Msg(fmt.Sprintf("Error unmarshalling json data: %s", err.Error()))
			break
		}

		rtt.Time_server = time.Now().UnixMicro()
		rtt.LenPayloadReaded = len(rtt.Data)

		//log.Info().Msg(fmt.Sprintf("<<<: %s Got '%s'", conn.RemoteAddr().String(), string(buf)))

		//
		//Escribir respuesta al cliente
		//----------------------------
		//

		//marshall json
		data, err := json.Marshal(rtt)
		if err != nil {
			//Log error
			log.Error().Msg(fmt.Sprintf("Json marshall failed '%s'", err.Error()))
			continue
		}
		//
		//Enviar data json
		//
		_, err = stream.Write(data)
		if err != nil {
			//Log error
			log.Error().Msg(fmt.Sprintf("Error '%s'", err.Error()))
			continue
		}

		//Int64("t_marshall", time_marshall).Int64("t_send", time_send).
		//log.Info().Msg(fmt.Sprintf("-> '%s' mesg: '%s'", conn.RemoteAddr().String(), data))

	}

	//Log error
	log.Info().Msg(fmt.Sprintf("Close connection client %s ", conn.RemoteAddr().String()))

}

// Nueva conexión TCP aceptada
func handleTCPConnection(conn net.Conn) {

	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr, TimeFormat: time.RFC3339})
	log.Info().Msg(fmt.Sprintf("New TCP connection <-- client from %s", conn.RemoteAddr().String()))

	defer conn.Close()

	// Echo local for data send by client
	for {
		//
		//Leer los datos
		//----------------------------
		//
		buf := make([]byte, maxMessage)

		// Read data from the client
		bytesReaded, err := conn.Read(buf)
		if err != nil {
			if err != io.EOF {
				//Log error
				log.Error().Msg(fmt.Sprintf("Client %s '%s'", conn.RemoteAddr().String(), err.Error()))
				break
			}
		}

		// Process and use the data (here, we'll just print it)
		// fmt.Printf("Received: %s\n", buf[:bytesReaded])

		//Unmarshalling JSON
		var rtt RTTQUIC

		if err := json.Unmarshal(buf[:bytesReaded], &rtt); err != nil { //El unmarshal se lee de un slice con los datos leidos, no mas para evitar datos erroneos
			log.Error().Msg(fmt.Sprintf("Error unmarshalling json data: %s", err.Error()))
			break
		}

		rtt.Time_server = time.Now().UnixMicro()
		rtt.LenPayloadReaded = len(rtt.Data)

		//log.Info().Msg(fmt.Sprintf("<<<: %s Got '%s'", conn.RemoteAddr().String(), string(buf)))

		//
		//Escribir respuesta al cliente
		//----------------------------
		//

		//marshall json
		data, err := json.Marshal(rtt)
		if err != nil {
			//Log error
			log.Error().Msg(fmt.Sprintf("Json marshall failed '%s'", err.Error()))
			continue
		}
		//
		//Enviar data json
		//
		// Send data to the server
		_, err = conn.Write(data)
		if err != nil {
			//Log error
			log.Error().Msg(fmt.Sprintf("Error '%s'", err.Error()))
			continue
		}

		//Int64("t_marshall", time_marshall).Int64("t_send", time_send).
		//log.Info().Msg(fmt.Sprintf("-> '%s' mesg: '%s'", conn.RemoteAddr().String(), data))

	}

	//Log error
	log.Info().Msg(fmt.Sprintf("Close connection client %s ", conn.RemoteAddr().String()))

}
