# Pruebas de Servicio QPing modo server en cluster kubernetes

##Estado de pruebas a 18.02.24
<span style="color:green">OK</span>: Compilación en go, modulo kayros.uno/qping

<span style="color:green">OK</span>: Creación de imagen en docker, proceso de build con golang y ejecución en imagen con ubuntu

<span style="color:green">OK</span>: Subida de imagen a dockerhub a repositotios kayrosuno e italtelspain

<span style="color:green">OK</span>: Creación de cluster de kubernetes con eksctl 

<span style="color:green">OK</span>: Pruebas de publicación de servicio de tipo Service NodePort

<span style="color:orange">OK</span>: Prueba de publicación de servicio de tipo Service LoadBalancer. Nota: el external IP utiliza un dirección DNS, al utilizar qping en modo cliente no va bien (revisar resolución de combres) pero si se resuelva con "dig <nombre> A" se observa que da 3 direcciones IP, si se utiliza alguna de ellas si llega al pod y responde.

<span style="color:red">KO</span>: Utilización de external IP en Service tipo Cluster

<span style="color:red">KO</span>: Utilización avanzada y conocimientos de load balancers en general.


#Configuracion

yaml de configuracion para crear los pods, deployment, servicios, etc de kubernetes.
Utiliza la imagen subida a italtelspain

### Crear namespace
'kubectl create namespace kayrosuno'

### Crear deployment

Hacer un deployment en el namespace kayrosuno

`
kubectl apply -f ./qping-server-deployment.yaml -n kayrosuno'
`
Se crea un deployment de pods con 1 container, el de qping 
Prueba con Redis: Se crea un deployment de pods con 2 containers, el de qping y un sidecar de redis para gestionas las estadisticas.


### Crear servicio
Podemos generar servicios de distintos modos

1. Nodeport
qping-server-svc-nodeport.yaml
`
kubectl apply -f ./qping-server-svc-nodeport.yaml -n kayrosuno
`

En este modo se crea un servicio nodeport, en los que todos los nodos con pods qping escuchan en un puerto determinado (30450) y mapean internamente a la ip:puerto de escucha de qping en los pods (25450)

2. ClusterIP

En este modo se crea un servicio ClusterIP con una dirección IP-Externa, en las pruebs realizadas no ha funcionado bien.....
En teoria se apunta a la IP externa que debe de dar acceso a los pods dentro .... balanceando? 
cual es la IP a poner??


3. LoadBalancer

En este modo se crea un loadbalancer en el caso de AWS crea un Network Load Balancer que balancea a los nodos, pods. 
Como funciona?
Desarrollar...



----

# Kubernetes 

**Exposing a Service**

The way in which a Service resource is exposed is controlled via its spec.type setting, with the following being relevant to our discussion:

*ClusterIP (as in the example above), which assigns it a cluster-private virtual IP and is the default
*NodePort, which exposes the above ClusterIP via a static port on each cluster node
*LoadBalancer, which automatically creates a ClusterIP, sets the NodePort, and indicates that the cluster’s infrastructure environment (e.g., cloud provider) is expected to create a load balancing component to expose the Pods behind the Service
Once a Pod targeted by the Service is created and ready, its IP is mapped to the ClusterIP to provide the load balancing between the Pods. A kube-proxy daemon, on each cluster node, defines that mapping in iptables rules (by default) for the Linux kernel to use when routing network packets, but itself is not actually on the data path.

Kubernetes also provides a built-in internal service discovery and communication mechanism. Each Service’s ClusterIP is provided with a cluster-private DNS name of <service-name>.<namespace-name>.svc.cluster.local form, accessible from Pods in the cluster.

To allow external access, LoadBalancer type is usually the preferred solution, as it combines the other options with load balancing capabilities and, possibly, additional features. In AWS these features, depending on the load balancer type, include Distributed Denial of Service (DDoS) protection with the AWS WAF service, certificate management with AWS Certificate Manager and many more.

![](https://d2908q01vomqb2.cloudfront.net/fe2ef495a1152561572949784c16bf23abb28057/2022/11/15/Expose-Kubernetes-1.png)

In Kubernetes, controller is an implementation of a control loop pattern, and its responsibility is to reconcile the desired state, defined by various Kubernetes resources, with the actual state of the system. A service controller watches for new Service resources to be created and, for those with the spec.type of LoadBalancer, the controller provisions a load balancer using the cloud provider’s APIs. It then configures the load balancers’ listeners and target groups and registers the Pods behind the Service as targets.

The way a provisioned load balancer routes to the Pods is specific to the load balancer type and the Service controller. For example, with AWS Network Load Balancer and Application Load Balancers you can configure target groups that use instance target type and route to NodeIP:NodePort on relevant nodes in the cluster or ip target type and route directly to Pods’ IPs.



**What is Ingress?**

Ingress is a built-in Kubernetes resource type that works in combination with Services to provide access to the Pods behind these Services. It defines a set of rules to route incoming HTTP/HTTPS traffic (it doesn’t support TCP/UDP) to backend Services and a default backend if none of the rules match. Each rule can define the desired host, path, and backend to receive the traffic if there is a match.

**Ingress Implementations**

If you were to create the above Ingress resource in a Kubernetes cluster, it would not do much, aside from creating its object representation in Kubernetes key-value data store: etcd.

For Ingress objects, it’s the responsibility of an Ingress controller to create the necessary wiring, provision the load balancing component, and reconcile the state of the cluster. There is no default Ingress controller included in the controller manager distributed with Kubernetes, so it must be installed separately.

In this post, we will discuss two possible approaches to an Ingress controller implementation: External Load Balancer and Internal Reverse Proxy, the differences between them, and the pros and cons of each implementation.

**External Load Balancer**

The approach is similar to the Service-based one we’ve described previously:

![](https://d2908q01vomqb2.cloudfront.net/fe2ef495a1152561572949784c16bf23abb28057/2022/11/15/Exposing-Kubernetes-2.png)


ALT TEXT: Ingress controller implementation using an external load balancer

The AWS implementation for Ingress controller, AWS Load Balancer Controller, translates the Ingress rules, parameters, and annotations into the Application Load Balancer configuration, creating listeners and target groups and connecting their targets to the backend Services.

This setup offloads the complexity of monitoring, managing, and scaling a routing mechanism to the cloud provider by using a managed, highly available, and scalable load balancing service. Additional features like Distributed Denial of Service attack (DDOS attack) protection or authentication can also be handled by the load balancer service.

**Internal Reverse Proxy**

In this case, the implementation is delegated to an internal, in-cluster Layer 7 reverse proxy (e.g., NGINX), that receives the traffic from outside the cluster and routes it to the backend Services based on Ingress configuration.

ALT TEXT:  Ingress controller implementation using an in-cluster reverse proxy
![](https://d2908q01vomqb2.cloudfront.net/fe2ef495a1152561572949784c16bf23abb28057/2022/11/15/Exposing-Kubernetes-3.png)

The installation, configuration, and maintenance of the reverse proxy is handled by the cluster operator, in contrast to the usage of the fully managed AWS Elastic Load Balancing service of the previous approach. As a result, while it may provide a higher degree of customization to fit the needs of the applications running in the cluster, this flexibility comes at a price.

The reverse proxy implementation places an additional element on the data path, which impacts the latency, but more importantly, it significantly increases the operational burden. Unlike the fully managed AWS Elastic Load Balancing service used by the previous implementation, it is the responsibility of the cluster’s operator to monitor, maintain, scale, and patch the proxy software and instances it runs on.

It is worth mentioning that in some cases, the two controller implementations can be used in parallel, handling separate segments of the cluster or in combination to form a complete solution. We’ll see an example of this in Part 3 of the series.

**Kubernetes Gateway API**

While we won’t go into its implementation details, Kubernetes Gateway API (currently in beta) is another specification that provides a way to expose applications in Kubernetes clusters, in addition to Service and Ingress resource types.

Gateway API is not currently supported by Amazon EKS, having only recently graduated to beta.

The Gateway API deconstructs the abstraction further into:

GatewayClass that, similar to IngressClass, denotes the controller to handle the API objects
Gateway that, similarly to Ingress, defines the entry point and triggers the creation of load balancing components, based on the handling controller and the gateway’s definition
HTTPRoute (with TLSRoute, TCPRoute, and UDPRoute to come), that defines routing rules that connect the gateway to the Services behind it, allow matching the traffic based on the host, headers and paths and splitting it by weight
ReferencePolicy, that allows to control which routes can be exposed via which gateways and which Services that can expose (including cross-namespace)
This is merely a cursory overview, but it should look very similar to what we’ve seen during the post:

ALT TEXT:  Gateway API implementation for traffic routing from a client to Pods
![](https://d2908q01vomqb2.cloudfront.net/fe2ef495a1152561572949784c16bf23abb28057/2022/11/15/Exposing-Kubernetes-4.png)

The actual provisioning of the load balancing components by the controller, missing from the diagram above, can take either of the routes (external load balancer or in-cluster reverse proxy) or hook into a different paradigm, like service mesh.

**Conclusion**

In Part 1 of the series, we discussed several ways to expose applications running in a Kubernetes cluster: Service-based with an external load balancer and Ingress-based with an external load balancer or an in-cluster Layer 7 reverse proxy. We briefly touched on the up-and-coming Kubernetes Gateway API that aims to provide further control over how the applications are exposed.

During the rest of the series we focus on the Ingress-based implementations with AWS Load Balancer Controller and NGINX Ingress Controller, discuss their setup and configuration, and walk through a set of examples.
