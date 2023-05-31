---
title: "Certified kubernetes administrator note"
date: 2022-11-29T11:17:12+07:00
draft: true
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
