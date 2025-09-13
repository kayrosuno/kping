/*
Copyright © 2023-2024 Alejandro Garcia (iacobus75@gmail.com)

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
	"crypto/rand"
	"crypto/rsa"
	"crypto/tls"
	"crypto/x509"
	"encoding/pem"
	"math/big"
	"time"
)

const sPortDefault = "25450"   //Puerto por defecto de escucha
const iPortDefault int = 25450 //Puerto por defecto de escucha

// const message = "Mensaje de prueba" //Mensaje de prueba por defecto
// var wg sync.WaitGroup               //grupo de sincronización de threads
var Program = "qping"   //Nombre del programa
var Version = "0.3.0"   //Version actual
const maxMessage = 1024 //Longitud en bytes maximo del mensaje
const MAX_TIME_READ_DEADLINE = time.Second * 5

// Struct for RTT QUIC
type RTTQUIC struct {
	Id               int64  // id del mensaje.
	Time_client      int64  // local time at client
	Time_server      int64  // local time at server    `json:"Time_server,omitempty"`
	LenPayload       int    // len payload data
	LenPayloadReaded int    // len data readed on server side for payload (for MTU discovery?) `json:"LenPayloadReaded,omitempty"`
	Data             []byte // data of payload
}

const (
	// iota se inicializa a 0 en el primer const de un bloque.
	// Cada línea subsiguiente incrementa iota en 1.
	// Aquí, definimos que cada unidad es un múltiplo de nanosegundos para comparación.
	Nanosegundo     int = 1                   // 1 nanosegundo
	Microsegundo    int = 1000 * Nanosegundo  // 1000 nanosegundos
	Milisegundo     int = 1000 * Microsegundo // 1000 microsegundos = 1,000,000 nanosegundos
	Milisegundo_500 int = 500 * Milisegundo
	Milisegundo_250 int = 250 * Milisegundo
	Milisegundo_100 int = 100 * Milisegundo
	Segundo         int = 1000 * Milisegundo // 1000 milisegundos = 1,000,000,000 nanosegundos
)

// Setup a bare-bones TLS config for the server
func GenerateTLSConfig() *tls.Config {
	key, err := rsa.GenerateKey(rand.Reader, 1024)
	if err != nil {
		panic(err)
	}
	template := x509.Certificate{SerialNumber: big.NewInt(1)}
	certDER, err := x509.CreateCertificate(rand.Reader, &template, &template, &key.PublicKey, key)
	if err != nil {
		panic(err)
	}
	keyPEM := pem.EncodeToMemory(&pem.Block{Type: "RSA PRIVATE KEY", Bytes: x509.MarshalPKCS1PrivateKey(key)})
	certPEM := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: certDER})

	tlsCert, err := tls.X509KeyPair(certPEM, keyPEM)
	if err != nil {
		panic(err)
	}
	return &tls.Config{
		Certificates: []tls.Certificate{tlsCert},
		NextProtos:   []string{"kayros.uno"},
		//NameToCertificate: ,
	}
}
