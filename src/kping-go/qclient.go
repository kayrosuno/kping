/*
Copyright © 2023-2024 Alejandro Garcia <iacobus75@gmail.com>  <alejandro@kayros.uno>

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
package main

import (
	"atomicgo.dev/keyboard"
	"atomicgo.dev/keyboard/keys"
	"context"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"github.com/quic-go/quic-go"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"net"
	"os"
	"os/signal"
	"strconv"
	"time"
)

// We start a server echoing data on the first stream the client opens,
// then connect with a client, send the message, and wait for its receipt.
const message = "qclient rtt message"

// Time in seg to wait to send another ping request
var pingWaitns = Segundo

// Channels
var chEndSignal = make(chan os.Signal)
var chEndClient = make(chan bool)
var chKeyUp = make(chan bool)
var chKeyDown = make(chan bool)

// RTT
var rtt_min int64 = 0.0
var rtt_max int64 = 0.0
var rtt_med int64 = 0.0
var loss = 0

////type SendDelay int
//const {
//	100ms SendDelay = iota
//	250ms
//	500ms
//	1000ms
//}

// Main echo client
// llamada -> qgo ipaddress:port
func QClient(bquic bool, args []string) {

	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr, TimeFormat: time.RFC3339})
	log.Info().Str(Program, Version).Msg("kping client mode")
	log.Info().Msg(fmt.Sprintf("Delay: " + strconv.Itoa(Delay)))

	//Flag Delay
	pingWaitns = Delay * 1000 * 1000. //Delay from ms to ns

	// Check UDP addresses
	var argsConnection = ""
	if bquic {
		argsConnection = args[0]
		udpAdr, err := net.ResolveUDPAddr("udp", argsConnection)
		//log.Info().Str("arg0", args[0]).Msg("<< args[0]")
		if err != nil {
			log.Panic().Msg(err.Error())
			panic(err.Error())
		}
		log.Info().Str("IP:", udpAdr.IP.String()).Str("Port", fmt.Sprint(udpAdr.Port)).Msg("Connecting to remote QUIC peer")
		//Check parameters
		tlsConf := &tls.Config{
			InsecureSkipVerify: true,
			NextProtos:         []string{"kayros.uno"},
		}
		//Conectar al servidor QUIC remoto
		conn, err := quic.DialAddr(context.Background(), argsConnection, tlsConf, nil)
		if err != nil {
			//Log error
			log.Error().Msg(fmt.Sprintf("'%s'\n", err.Error()))
			return
		}

		go clientLoop(conn, nil)
	} else {
		argsConnection = args[0]
		tcpAdr, err := net.ResolveTCPAddr("tcp", argsConnection)
		//log.Info().Str("arg0", args[0]).Msg("<< args[0]")
		if err != nil {
			log.Panic().Msg(err.Error())
			panic(err.Error())
		}
		log.Info().Str("IP:", tcpAdr.IP.String()).Str("Port", fmt.Sprint(tcpAdr.Port)).Msg("Connecting to remote TCP peer")
		//Conectar al servidor QUIC remoto
		conn, err := net.Dial("tcp", tcpAdr.String())
		if err != nil {
			//Log error
			log.Error().Msg(fmt.Sprintf("'%s'\n", err.Error()))
			return
		}
		//Cerrar diferido
		defer conn.Close()
		go clientLoop(nil, conn)
	}

	//UUID
	//var uuid = uuid.New().String()

	//Listen systems signal
	signal.Notify(chEndSignal, os.Interrupt)
	signal.Notify(chEndSignal, os.Kill)

	go readKeyInputLoop()

	//wait for main goroutine, till end of client or signal
	//<-chEndSignal || <-chEndClient

	for {
		select {
		//case s := <-chEndSignal:
		//	log.Info().Msg(fmt.Sprintf("Exit, signal received '%d'", s))
		//	printSummary()
		//	os.Exit(-1)

		case <-chEndClient:
			//log.Info().Msg(fmt.Sprintf("Exit, end client"))
			printSummary()
			os.Exit(0)

		case <-chKeyUp:
			//log.Info().Msg(fmt.Sprintf("chKeyUp pressed"))
			switch pingWaitns {
			case Segundo:
				pingWaitns = Milisegundo_500
				log.Info().Msg(fmt.Sprintf("Delay: 500ms"))
			case Milisegundo_500:
				pingWaitns = Milisegundo_250
				log.Info().Msg(fmt.Sprintf("Delay: 250ms"))
			case Milisegundo_250:
				pingWaitns = Milisegundo_100
				log.Info().Msg(fmt.Sprintf("Delay: 100ms"))
				//case Milisegundo_100:
			}
		case <-chKeyDown:
			//log.Info().Msg(fmt.Sprintf("chKeyDown pressed"))
			switch pingWaitns {
			//case Segundo: pingWaitns= Milisegundo_500
			case Milisegundo_500:
				pingWaitns = Segundo
				log.Info().Msg(fmt.Sprintf("Delay: 1seg"))
			case Milisegundo_250:
				pingWaitns = Milisegundo_500
				log.Info().Msg(fmt.Sprintf("Delay: 500ms"))
			case Milisegundo_100:
				pingWaitns = Milisegundo_250
				log.Info().Msg(fmt.Sprintf("Delay: 250ms"))
			}
			//default:
			//	log.Debug().Msg(fmt.Sprintf("Exit, end select "))
		}

		//Esperar 1 seg TODO: eliminar
		time.Sleep(1 * time.Second)
	}

}

// / INput Loop
func readKeyInputLoop() {

	keyboard.Listen(func(key keys.Key) (stop bool, err error) {
		switch key.Code {
		case keys.CtrlC:
			chEndSignal <- os.Interrupt
			return true, nil // Stop listener by returning true on Ctrl+C
		case keys.Up:
			chKeyUp <- true
			return false, nil
		case keys.Down:
			chKeyDown <- true
			return false, nil
		default:
			fmt.Println("\r" + key.String()) // Print every key press
			return false, nil                // Return false to continue listening
		}
	})

}

func printSummary() {
	log.Info().Msg(fmt.Sprintf("Summary: rtt MIN(ms)=%f, rtt MED(ms)=%f, rtt MAX(ms)=%f", float64(rtt_min)/1000, float64(rtt_med)/1000, float64(rtt_max)/1000))
	//TODO: calcular tiempos correctamente, y
}

// Client Loop for QUIC
func clientLoop(connQuic *quic.Conn, connTCP net.Conn) { //stream quic.Stream) {

	//Stream Quic
	var stream *quic.Stream
	var err error
	var bytesReaded int

	if connQuic != nil {
		stream, err = connQuic.OpenStreamSync(context.Background())
		if err != nil {
			//Log error
			log.Error().Msg(fmt.Sprintf("Error '%s'", err.Error()))
			return
		}
		//Cerrar diferido
		defer stream.Close()
	}
	if connTCP != nil {
		defer connTCP.Close()
	}

	//Bucle de envío continuo del cliente
	for i := 1; true; i++ {

		buf := make([]byte, maxMessage) //Buffer

		//Crear el mensaje
		var rttMensaje RTTQUIC
		rttMensaje.Id = int64(i)
		rttMensaje.Data = []byte(message)
		rttMensaje.LenPayload = len(message)

		var time_init = time.Now().UnixMicro()
		rttMensaje.Time_client = time_init
		rttMensaje.Time_server = 0
		rttMensaje.LenPayloadReaded = 0

		data, err := json.Marshal(rttMensaje)
		//var time_marshall = time.Now().UnixMicro() - time_init

		if err != nil {
			//Log error
			log.Error().Msg(fmt.Sprintf("Json marshall failed '%s'", err.Error()))
			chEndClient <- true //Notify client exit
			return
		}
		//
		//Enviar data json
		//----------------------------
		//
		//var time_send = time.Now().UnixMicro() - time_init
		//Conexion es QUIC
		if connQuic != nil && stream != nil {
			_, err = stream.Write(data)
			if err != nil {
				//Log error
				log.Error().Msg(fmt.Sprintf("Error '%s'", err.Error()))
				chEndClient <- true //Notify client exit
				return
			}
			//var time_sended = time.Now().UnixMicro() - time_init
			//log.Info().Int64("t_marshall", time_marshall).Int64("t_send", time_send).Msg(fmt.Sprintf("-> '%s' mesg: '%s'", args[0], data))

			//
			//Leer echo desde el server
			//
			// TODO
			err = stream.SetReadDeadline(time.Now().Add(time.Second)) // 1seg
			if err != nil {
				//Log error
				log.Error().Msg(fmt.Sprintf("Error '%s'", err.Error()))
				chEndClient <- true //Notify client exit
				return
			}

			//var bytes_leidos = 0

			bytesReaded, err = stream.Read(buf)
			if err != nil {
				//Log error
				log.Error().Msg(fmt.Sprintf("Error '%s'", err.Error()))
				chEndClient <- true //Notify client exit
				return
			}
		}

		//Conexion es TCP
		if connTCP != nil {
			_, err = connTCP.Write(data)
			if err != nil {
				//Log error
				log.Error().Msg(fmt.Sprintf("Error '%s'", err.Error()))
				chEndClient <- true //Notify client exit
				return
			}
			//Leer echo desde el server
			//
			// TODO check reply
			// Read data from the client
			//readline for TCP
			connTCP.SetReadDeadline(time.Now().Add(MAX_TIME_READ_DEADLINE))
			bytesReaded, err = connTCP.Read(buf)
			if err != nil {
				//Log error
				log.Error().Msg(fmt.Sprintf("Error '%s'", err.Error()))
				chEndClient <- true //Notify client exit
				return
			}
		}

		//Time RTT
		var rtt_time = time.Now().UnixMicro() - time_init

		// min,med,max
		if rtt_time < rtt_min {
			rtt_min = rtt_time
		} else {
			if rtt_min == 0 {
				rtt_min = rtt_time
			}
		}
		if rtt_time > rtt_max {
			rtt_max = rtt_time
		}

		//Media rtt
		var nuevaCantidadNumeros int64 = int64(i) + 1
		rtt_med = ((rtt_time + (rtt_med * int64(i))) / nuevaCantidadNumeros)

		//Unmarshall answer from server
		var rttServer RTTQUIC

		if err := json.Unmarshal(buf[:bytesReaded], &rttServer); err != nil { //El unmarshal se lee de un slice con los datos leidos, no mas para evitar datos erroneos
			log.Error().Msg(fmt.Sprintf("Error unmarshalling json data: %s", err.Error()))
			continue
		}

		//log.Info().Msg(fmt.Sprintf("<-  mesg: '%s'", datos_leidos))
		log.Info().
			//Int64("t_marshall", time_marshall).
			Int64("id", rttServer.Id).
			Int64("rtt usec", rtt_time).
			//Int64("t_server", rttServer.Time_server-rttMensaje.Time_client).
			//cInt64("t_send", time_send).
			//Msg(fmt.Sprintf(" RT='%d'usec", rtt_time))
			Msg("") //fmt.Sprintf("<- '%s' mesg: '%s'", args[0], data))

		select {
		case s := <-chEndSignal:
			log.Info().Msg(fmt.Sprintf("Exit, signal received '%d'", s))
			chEndClient <- true
		default:
			//Esperar delay desde inicio
			timeDelay := pingWaitns - int(rtt_time)
			if timeDelay > 0 {
				time.Sleep(time.Duration(timeDelay))
			}
		}
	}
}
