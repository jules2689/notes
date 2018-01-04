---
title: Kubernetes
date: 2017-04-05T19:24:08-04:00
categories:
- computers
tags:
- computers
- kubernetes
---



Kubernetes is an orchestration layer to manage containerized applications. In a traditional system, you either run on bare metal or with containers on a host. With Kubernetes, containerized applications and services can be spread across many hosts. This means if one host goes down, the work and containers can be redistributed to other nodes.

Example:


<!---
```diagram
graph BT
  subgraph Kubernetes
    Node1((Node1))-\->Cluster
    Node2((Node2))-\->Cluster
    Node3((Node3))-\->Cluster
  end
  subgraph Node
    App-\->Node3
    MySQL-\->Node3
    Redis-\->Node3
    Nginx-\->Node3
  end
Nginx---Internet
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/57bfba886cdabd6803742ab499d85e11.png' alt='diagram image' height='250px'>


Each node can contain random services, or it can contain specific ones. In the example above, a node contains one of every service required to run an application. This means that if a node goes down, the work can be redistributed to other nodes, without any downtime, while Kubernetes also works on bringing that node back to life.

Glossary
---
Borrowed from [Karan Thukral](https://github.com/karanthukral)
- Cluster – The set of machines you are running the application on
- Node – A single machine
- Pods – A group of containers that work together to achieve a certain task. 
- Service – A way to externally expose (externally and internally) a set of pods that work together
- Labels – An arbitrary tag that can be places on kubernetes resources and can be used to filter on
- Selectors – Way for the user to identify a set of objects based on labels assigned to them
- Controller – A reconciliation loop that drives current state towards desired state
