---
title: Kubernetes Configs
date: 2017-04-05T19:24:08-04:00
categories:
- computers
tags:
- computers
- kubernetes
---



To run a Kubernetes cluster, you can group services in `namespace`s. This will keep a grouping of services and deployments in separate namespaced sections. To create a namespace run `kubectl create namespace <NAMESPACE>`

After creating a namespace, you can apply configurations. In particular you want `deployment`s which will run the containers. `Service`s expose those deployments within the cluster. This makes them accessible to other deployments.

Below are pieces of configurations. You can combine many together and apply them all at once.

For example, my website defines a number of configurations all in one yaml file.

- a deployment for an app server
- exposes the app server with a service definition
- a deployment and service is running for Postgres
- In the App server defintion, we can access the database using `postgres.NAMESPACE.svc.cluster.local`
- Finally, an ingress is defined to expose the app on a URL.

Run `kubectl apply -f PathToYaml.yml -n NAMESPACE` to apply it.

### Deployment

A deployment should specify a few things. Namely, it should specify the docker image you would like to run, volumes you'd like to mount, and environment variables to use in the container.

```yml
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: website
  namespace: website
spec:
  replicas: 1 # We have one backup replica
  template:
    metadata:
      labels:
        name: website
        app: website
        environment: production
    spec:
      containers:
      - name: website
        # This image will pull from the docker registry
        # I have built and pushed this image already
        image: jules2689/website:v1.03
        imagePullPolicy: Always
        # The container runs the application on port 3000
        ports:
          - containerPort: 3000
            name: http
        # These are the environment variables to use
        env:
          - name: ENV
            value: production
          - name: RAILS_ENV
            value: production
          - name: RAILS_LOG_TO_STDOUT
            value: '1'
          - name: ASSET_HOST
            value: 'http://website2.jnadeau.ca'
          - name: DATABASE_URL
            # This value actually corresponds to another deployment. Once we're done we can refer
            # to other deployments by `NAME.NAMESPACE.svc.cluster.local:PORT`
            value: postgres://postgres@postgres.website.svc.cluster.local:5432/website_production
        # This will point the volume with the name 'ejson-keys' to `/opt/ejson/keys`
        volumeMounts:
          - name: ejson-keys
            mountPath: "/opt/ejson/keys"
            readOnly: true
      # This will load the secret with the name `ejson-keys` to the volume `ejson-keys`
      # The secret was set manually beforehand.
      volumes:
      - name: ejson-keys
        secret:
          secretName: ejson-keys
```

### Service

Services will expose the deployment internally.

```yml
---
apiVersion: v1
kind: Service
metadata:
  name: website
  namespace: website
  labels:
    name: website
    app: website
    environment: production
spec:
  type: NodePort # This will open up a port from port 80 to port 3000 in the deployment
  ports:
  - port: 80
    name: http
    targetPort: 3000
  selector:
    name: website
    app: website
    environment: production
```

### Ingress

Ingresses will setup network intakes from external sources. In my setup, I will be taking data on port 80 from `website.jnadeau.ca` and passing it along to the service called website.

I have an Nginx deployment and service running elsewhere. That deployment is configured to pass the data upstream to registered deployements based on the host.

```yml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: website
  namespace: website
  labels:
    name: website
    app: website
    environment: production
spec:
  rules:
  - host: website2.jnadeau.ca
    http:
      paths:
      - backend:
          serviceName: website
          servicePort: 80
```
