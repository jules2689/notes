# Kubernetes
Kubernetes is an orchestration layer to manage containerized applications. In a traditional system, you either run on bare metal or with containers on a host. With Kubernetes, containerized applications and services can be spread across many hosts. This means if one host goes down, the work and containers can be redistributed to other nodes.

Example:



<!---
```diagram
graph BT
  Node1-\->Kubernetes
  Node2-\->Kubernetes
  Node3-\->Kubernetes
  MySQL-\->Node
  Redis-\->Node
  App-\->Node
```
--->
<img src='https://jules2689.github.io/gitcdn/images/website/images/diagram/115f71ca7d6d0c20de793c3d38bdbfc3.png' alt='diagram image' height='250px'>


Each node can contain random services, or it can contain specific ones. In the example above, a node contains one of every service required to run an application. This means that if a node goes down, the work can be redistributed to other nodes, without any downtime, while Kubernetes also works on bringing that node back to life.
