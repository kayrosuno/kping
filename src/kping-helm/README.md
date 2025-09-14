# Crear helm chart



## Crear directorio del chart
Crear la estructura del repositorio
´
helm create kping
´
Dentro del repositorio eliminar las templates creadas por defecto
Despues creamos las templates que se ejecutaran en kubernetes, por ejemplo
el namespace.yaml para crear un namespace
deployment.yaml para crear un deployment
service.yaml para crar un servicio

en el directorio raiz del chart debe de haber:
Chart.yaml para contenr la version de la aplicacion
se recomienda que este un fichero de licencia y un README


## Crear paquete

Creamos el paquete que generara el contenido del directorio en un fichero xxxxx.tgz
´
helm package kping --url https://kayrosuno.github.io/kping/
´

## Crear el indice
desde donde esta el fichero generado xxx.tgz creamos un fichero index.yaml

´
touch index.yaml
´

Despues ejecutamos para que helm actualice el index.yaml, y le indicamos las urls donde se podra descargar este chart

´
helm repo index . --url https://kayrosuno.github.io/kping/
´

Subimos a github el index.haml y el xxxx.tgz. en nuestro caso esta en la carpeta docs. donde en github le hemos dicho que crea una github pages.



