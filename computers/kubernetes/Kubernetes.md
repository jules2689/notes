# Kubernetes
Kubernetes is an orchestration layer to manage containerized applications. In a traditional system, you either run on bare metal or with containers on a host. With Kubernetes, containerized applications and services can be spread across many hosts. This means if one host goes down, the work and containers can be redistributed to other nodes.

Example:

```diagram
Node --> Kubernetes
Node --> Kubernetes
Node --> Kubernetes

MySQL --> Node
Redis --> Node
App Server --> Node
```

Each node can contain random services, or it can contain specific ones. In the example above, a node contains one of every service required to run an application. This means that if a node goes down, the work can be redistributed to other nodes, without any downtime, while Kubernetes also works on bringing that node back to life.
