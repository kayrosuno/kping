# Crear helm chart



## Crear directorio del chart
Crear la estructura del repositorio
``
helm create kping
``
Dentro del repositorio eliminar las templates creadas por defecto
Despues creamos las templates que se ejecutaran en kubernetes, por ejemplo
el namespace.yaml para crear un namespace
deployment.yaml para crear un deployment
service.yaml para crar un servicio en el directorio raiz del chart debe de haber:
Chart.yaml para contener la version de la aplicacion
se recomienda que este un fichero de licencia y un README


## Crear paquete

Creamos el paquete que generara el contenido del directorio en un fichero xxxxx.tgz
``
helm package kping --url https://kayrosuno.github.io/kping/
``

## Crear el indice
desde donde esta el fichero generado xxx.tgz creamos un fichero index.yaml

``
touch index.yaml
``

Despues ejecutamos para que helm actualice el index.yaml, y le indicamos las urls donde se podra descargar este chart

`` 
helm repo index . --url https://kayrosuno.github.io/kping/
``

Subimos a github el index.haml y el xxxx.tgz. en nuestro caso esta en la carpeta docs. donde en github le hemos dicho que crea una github pages.



# Instalacion utilizando helm chart

## Buscar el paquete
Buscar kping en artifacthub

``
helm search hub kping
``

da esta salida a 14.09.25

``
URL                                             	CHART VERSION	APP VERSION	DESCRIPTION                                   
https://artifacthub.io/packages/helm/kping/kping	0.3.2        	0.3.2      	kping helm chart to test Kubernetes networking
``

``helm search repo ``

busca en los repositorios que ha agregado a su cliente de helm local


## Añadir el repositorio a helm local

``
helm repo add kayrosuno https://kayrosuno.github.io/kping/
``
> "kayrosuno" has been added to your repositories

to check:

``
helm repo list
``

output local:
>NAME             ______________    	URL                                               \
prometheus-community	https://prometheus-community.github.io/helm-charts \
grafana             	https://grafana.github.io/helm-charts             \
kayrosuno           	https://kayrosuno.github.io/kping    
>  

## Instalar el chart
Por defecto el contexto de kubeconfig activo es el utilizado

``
helm install kping-server kayrosuno/kping
``
output:
>NAME: kping-server \
LAST DEPLOYED: Mon Sep 15 00:02:16 2025 \
NAMESPACE: default\
STATUS: deployed\
REVISION: 1\
TEST SUITE: None\
NOTES:\
Thank you for installing kping.\
\
Your release is named kping-server.\
\
To learn more about the release, try:\
\
$ helm status kping-server\
$ helm get all kping-server\
> 