---
title: "Certified kubernetes administrator note"
date: 2022-11-29T11:17:12+07:00
draft: true
---

# Architecture
## Master Node: 
    - Responsible for managing the K8s cluster, storing information about the nodes, containers, ...
### ETCD:
    - Database that stores informations in key-value format
### Scheduler
    - Identifies the right node to place a container based on the containers resource requirements, worker policies, constraints, ...
### Controllers:
    - Node Controller: Responsible for onboarding new nodes to the cluster, handling situations where nodes are unavailable or get destroyed, 
    - Replication Controller: ensures that the desired number of containers are running at all times in a replication group
### Kube API: 
    - Responsible for orchestrating all operations within the cluster
## Worker Node: 
### Kubelet
    - Agent that runs on each node in a cluster. It listens intructions from kube-api server, deploys and destroys
### Kube-proxy
    - Ensures necessary rules in place on the worker nodes to allow all containers running on them to reach each other.
