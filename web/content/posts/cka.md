---
title: "Certified kubernetes administrator note"
date: 2022-11-29T11:17:12+07:00
draft: false
---

# Architecture
## Overview
### Master Node: 
    - Responsible for managing the K8s cluster, storing information about the nodes, containers, ...
### ETCD:
    - Database that stores informations in key-value format
### Scheduler
    - Identifies the right node to place a container based on the containers resource requirements, worker policies, constraints, ...
    - 
### Controllers:
    - Types:
        - Node Controller: Responsible for onboarding new nodes to the cluster, handling situations where nodes are unavailable or get destroyed, 
        - Replication Controller: ensures that the desired number of containers are running at all times in a replication group
            + 
    - Workflows:
        - Monitoring status from the nodes and taking some actions to keep applications running.
        - it does that through kube-apiserver
        - ensures that the desired number of containers are running at all times in a replication group
        - if pod dies, it creates another one
### Kube API: 
    - Responsible for orchestrating all operations within the cluster
    - Kube-api authenticates user
    - Kube-api Validates request
    - Kube-api Retrieves data
    - Kube-api Updates etcd
    - Scheduler
    - Kubelet
### Worker Node: 
### Kubelet
    - Agent that runs on each node in a cluster. It listens intructions from kube-api server, deploys and destroys
### Kube-proxy
    - Ensures necessary rules in place on the worker nodes to allow all containers running on them to reach each other.
    - Kube-proxy is a process that runs on each node in the Kubernetes cluster. Its job is to look for new services, and every time a new service is created,it creates the appropriate rules on each node to forward traffic to those services to the backend pods.One way it does this is using iptables rules.In this case, it creates an iptables rule on each node in the cluster to forward traffic heading to the IP of the service
## Core Concept
### Pod
    - A single instance of application
    - Have one or multiple containers
```
kubectl run --image=nginx nginx
```
### Replica Set vs Replica Controller
    - Replica
### Services
    - Map requests to the pod running the web containers
    - Node Port:
        - Mapping a port on the node to a port on the pod
    - Cluster IP: Each service gets an IP and name assigned to it inside the cluster, and that is the name that should be used by other pods to access the service. This type of service is known as cluster IP.
    - Load Balancer
        + Set the type of service to load balancer in an unsupported environment,like VirtualBox, or, you know,any other environments,then it would have the same effect as setting it to node port.
        + Integrate natively with cloud LB

### Namespaces: 
    - Isolate envrionment
    - Kubernetes creates a set of pods and services for its internal purpose, such as those required by the networking solution, the DNS service, etcetera. To isolate these from the user and to prevent you from accidentally deleting or modifying these services, Kubernetes creates them under another name space created at cluster startup named kube-system.
    - A third name space created by Kubernetes automatically is called kube-public. This is where resources that should be made available to all users are created.
```
    Format: service-name.namespace.service.domain
    Example: db-service.dev.svc.cluster.local
```
### Static Pods
    - You can configure the kubelet to read the pod definition files from a directory on the server designated to store information about pods.
    - default pod-manifest-path=/etc/kubernetes/manifest
## Lifecyle and management
### Commands
    - Docker EntryPoint: append new variable
    - Docker Cmd: will be overwrite
    - ** Note **: K8s command overwrite entrypoint docker. args overwrite command docker
### ConfigMap
    - Config maps are used to pass configuration data in the form of key value pairs in Kubernetes.
### Secrets
    - Secrets are used to store sensitive information like passwords or keys.They're similar to ConfigMaps except that they're stored in an encoded format.
### Patterns
    - Sidecar pattern
    - adapter pattern
    - ambassador pattern
## Cluster maintenance
### OS Upgraded
- drain: move exist pods to other nodes and new nodes are unscheduled on this node
```
    kubectl drain <node>
```
- cordon: new pods are unscheduled on this node
```
kubectl cordon <node>
```
### Cluster upgraded

- Master:
    - Upgrade kubeadm
    - Run 
    ```
    kubectl upgrade apply <version>
    ```
    - Upgrade kubelet by apt
- Node:
    - Upgrade kubeadm
    - upgrade node config
    ```
    kubeadm upgrade node config --kubelet-version <version>
    ```
    - Restart kubelet
    - Strategy:
        + All at once
        + One node at time
        + Replace old node with new node

## Security
### Resources and Verbs
```
kubectl api-resources --sort-by name -o wide
```
### RBAC

### Cluster Role
- Assign role
```
k create clusterrole <name> --resources=nodes --verb get,watch,list,get,create,delete
k create clusterrolebinding <name> --user michelle --clusterrole node-admin 
```
- check permission
```
kubectl auth can-i list storageclasses --as michelle
```

```
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: storage-admin
rules:
- apiGroups: [""]
  resources: ["persistentvolumes"]
  verbs: ["get", "watch", "list", "create", "delete"]
- apiGroups: ["storage.k8s.io"]
  resources: ["storageclasses"]
  verbs: ["get", "watch", "list", "create", "delete"]

---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: michelle-storage-admin
subjects:
- kind: User
  name: michelle
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: storage-admin
  apiGroup: rbac.authorization.k8s.io
```

### Service Account
- 
```
kubectl create serviceaccount dashboard-sa
k create token dashboard-sa
```
- Set service account by cmd
```
kubectl set serviceaccount deploy/web-dashboard dashboard-sa
```
### Image security
- Command
```
kubectl create secret docker-registry regcred --docker-server=<your-registry-server> --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email>

kubectl get secret regcred --output=yaml
```
- Inspecting
```
kubectl get secret regcred --output=yaml
```
### Docker Security
-  Unlike virtual machines, containers are not completely isolated from their host.Containers and the host share the same kernel.
- Containers are isolated using namespaces in Linux. The host has a namespace and the containers have their own namespace. All the processes run by the containers are in fact run on the host itself but in their own namespace. As far as the Docker container is concerned, it is in its own namespace
- By default, Docker runs a container with a limited set of capabilities. And so the processes running within the container do not have the privileges to say reboot the host or perform operations that can disrupt the host or other containers running on the same host.
- Docker capabilities
```
docker run --cap-add MAC-ADMIN ubuntu
docker run --cap-drop KILL ubuntu
docker run --privilleged KILL ubuntu
```
### Security Context
- Put below data into containers details
 ```
 securityContext:
   runAsUser: 1000
   capabilities:
     add: ["MAC_ADMIN"]
 ```

### Traffic
- Ingress: Ingoing
- Egress: Outgoing
- k8S allow any traffics from any pods in cluster
- Networking policy YAML 
```

```
- Solutions that support network policies
    - Kube-router
    - Calico
    - Romana
    - Weave-net
- Not Support:
    - Flannel
- Example yaml file
```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: internal-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      name: internal
  policyTypes:
  - Egress
  - Ingress
  ingress:
    - {}
  egress:
  - to:
    - podSelector:
        matchLabels:
          name: mysql
    ports:
    - protocol: TCP
      port: 3306

  - to:
    - podSelector:
        matchLabels:
          name: payroll
    ports:
    - protocol: TCP
      port: 8080

  - ports:
    - port: 53
      protocol: UDP
    - port: 53
      protocol: TCP
```
### Backup
- Resource Configurations
    - 
- ETCD Cluster
    - Restore
    ```
    ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/etcd/pki/ca.pem --cert=/etc/etcd/pki/etcd.pem --key=/etc/etcd/pki/etcd-key.pem snapshot restore /root/cluster2.db --data-dir <dir>
    ```
    - Backup
    ```
    ETCDCTL_API=3 etcdctl --endpoints=https://192.13.40.18:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot save /<dir>
    ```
### Certificate API
- Create CertificateSigningRequest
```
    openssl genrsa -out <name.key> 2048
    openssl req -new-key <name.key> -subj "/CN=jane" -out jane.csr

    cat <name.csr> | base64 |tr -d "\n"

```
```
-- csr file yaml example
---
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: <user>
spec:
  request: <base64 here>
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth

```
- Review requests
```
kubectl get csr
```
- Approve requests
```
kubectl certificate approve/deny <name>
```
- Shares certs to users

### Kube Config
## Storage
### Persistent volume
- PV
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-log
spec:
  accessModes:
    - ReadWriteMany
  capacity:
    storage: 100Mi
  hostPath:
    path: /pv/log
    type: DirectoryOrCreate
  persistentVolumeReclaimPolicy: Retain
```
- pvc
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: claim-log-1
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 50Mi
```
### Storage class:
- Support for dynamic provisioning
## Networking
### Switching
### DNS
- Name resolution: Transalating hostname to IP address
- Append this option into /etc/resolv.conf so server can query from dns server
```
nameserver 192.168.1.100
```
### Docker networking
- Network: none containers can't connect each other or outside the world
- Network: host 
- Network: bridge 
  + 
### CNI
### IPAM
- Weave, by default, allocates the IP range 10.32.0.0/12 for the entire network.
- From this range, the peers decide to split the IP addresses equally between them and assigns one portion to each node.
### Service Networking
- When a service is created, it is accessible from all pods on the cluster, irrespective of what nodes the pods are on.While a pod is hosted on a node, a service is hosted across the cluster. It is not bound to a specific node,but remember, the service is only accessible from within the cluster. This type of service is known as ClusterIP.
- Similarly, each node runs another component known as kube-proxy. kube-proxy watches the changes in the cluster through Kube API server,and every time a new service is to be created,kube-proxy gets into action.Unlike pods, services are not created on each node or assigned to each node. Services are a cluster-wide concept. They exist across all the nodes in the cluster.


### DNS in K8s

# Compare with docker swarm

While Docker Swarm offers a simpler networking model compared to Kubernetes, there are certain advanced networking features and use cases where Kubernetes outshines Docker Swarm. Here are some cases where Docker Swarm networking might fall short when compared to Kubernetes:

- Fine-grained Network Policies:

Kubernetes supports network policies that allow you to define rules for how pods can communicate with each other and other network endpoints. These policies enable fine-grained control over network traffic based on labels, namespaces, and other attributes. Docker Swarm does not offer native support for such fine-grained network policies, making it more challenging to implement strict network segmentation and access controls.
- Advanced Load Balancing and Ingress Controllers:

Kubernetes has a rich ecosystem of load balancers and ingress controllers that provide advanced traffic management features, including SSL termination, path-based routing, and header-based routing. While Docker Swarm provides built-in load balancing capabilities, it lacks the extensive features offered by Kubernetes' ecosystem of Ingress controllers like Nginx Ingress Controller, Traefik, or HAProxy Ingress.
- Service Mesh Integration:

Kubernetes has strong support for service mesh technologies like Istio and Linkerd, which enable advanced features such as traffic shaping, observability, and security at the service-to-service level. These features are essential for microservices architectures. While it's possible to integrate service mesh with Docker Swarm, Kubernetes has better support and integration due to its widespread adoption and larger community.
- Dynamic IP Assignment and DNS for Pods:

Kubernetes assigns each pod a unique IP address and DNS name, allowing for seamless communication between pods within the cluster. Docker Swarm also provides DNS-based service discovery, but it does not assign individual IP addresses to pods by default. This might limit certain use cases where direct communication between pods with unique IPs is necessary.
- Third-party Networking Plugins and Integrations:

Kubernetes has a broader ecosystem of third-party networking plugins and integrations, such as Calico, Flannel, and Cilium, which offer various networking features and performance optimizations. While Docker Swarm supports some networking plugins, Kubernetes' ecosystem is more mature and diverse, providing users with more options and flexibility to tailor networking solutions to their specific needs.

In summary, while Docker Swarm provides a straightforward networking model suitable for many use cases, Kubernetes offers more advanced networking features and integrations, making it better suited for complex microservices architectures and environments requiring fine-grained network control and observability.