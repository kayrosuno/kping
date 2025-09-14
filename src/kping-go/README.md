# KPing go version
Version de KPing para go

## Build
En el directorio de kping compilar para go.

#### Compilar
El modulo de go es: kayros.uno/kping

`go build kayros.uno/kping`


#### Crear imagen de docker

`
docker image build -t kayrosuno/kping-amd64:0.3.2   -t kayrosuno/kping-amd64:latest  .
`
`
docker image build -t kayrosuno/kping-arm64:0.3.2   -t kayrosuno/kping-arm64:latest  .
`
Se utiliza el fichero Dockerfile, que establece dos fases, una para compilar go con la imagen golang y otra para la distribución basada en la imagen de ubuntu
Hay diferentes ficheros Dockerfile con distintas arquitecturas


### Push al repositorio de docker.io 
`docker image push kayrosuno/kping:0.3.2`
También se puede enviar desde docker desktop.

# Run kping
### Run container y hacer port forward al 25450 en udp!!
`docker container run -it -p 25450:25450/udp  kping:0.3.1
`


### Run kping as server
Ejecutar kping en modo server:

`kping server <ip_container>:25450`


### Run kping as client
Ejecutar kping en modo cliente:

`kping <ip_container>:25450`

### Run kping as client setting initial delay
Ejecutar kping en modo cliente con delay de 500ms:

`kping <ip_container>:25450 -d 500`

### Use keyup and keydown
Use keyup and keydown to reduce or increase delay time between pings.

# Licencia

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
