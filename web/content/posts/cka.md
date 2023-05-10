---
title: "Certified kubernetes administrator note"
date: 2022-11-29T11:17:12+07:00
draft: true
---

# Architecture
## Overview
    - Kube-api authenticates user
    - Kube-api Validates request
    - Kube-api Retrieves data
    - Kube-api Updates etcd
    - Scheduler
    - Kubelet

## Master Node: 
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
    - Workflows:
        - Monitoring status from the nodes and taking some actions to keep applications running.
        - it does that through kube-apiserver
        - ensures that the desired number of containers are running at all times in a replication group
        - if pod dies, it creates another one
### Kube API: 
    - Responsible for orchestrating all operations within the cluster
## Worker Node: 
### Kubelet
    - Agent that runs on each node in a cluster. It listens intructions from kube-api server, deploys and destroys
### Kube-proxy
    - Ensures necessary rules in place on the worker nodes to allow all containers running on them to reach each other.
    - Kube-proxy is a process that runs on each node in the Kubernetes cluster. Its job is to look for new services, and every time a new service is created,it creates the appropriate rules on each node to forward traffic to those services to the backend pods.One way it does this is using iptables rules.In this case, it creates an iptables rule on each node in the cluster to forward traffic heading to the IP of the service
