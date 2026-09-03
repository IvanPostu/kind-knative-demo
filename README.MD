# Kind Knative demo

```sh
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.33.0/kind-linux-amd64

chmod +x ./kind

mv ./kind ./bin
```

```sh
cat > clusterconfig.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
    ## expose port 31080 of the node to port 80 on the host
  - containerPort: 31080
    hostPort: 80
    ## expose port 31443 of the node to port 443 on the host
  - containerPort: 31443
    hostPort: 443
EOF
```

```sh
kind delete cluster --name knative

kind create cluster --name knative --config clusterconfig.yaml
```

```sh
kubectl apply --filename https://github.com/knative/serving/releases/download/knative-v1.15.0/serving-crds.yaml

kubectl apply --filename https://github.com/knative/serving/releases/download/knative-v1.15.0/serving-core.yaml
```

```sh
kubectl create namespace knative-eventing

# kubectl apply -f https://github.com/knative-extensions/eventing-rabbitmq/releases/download/knative-v1.15.0/rabbitmq-broker.yaml

kubectl apply -f ./rabbitmq-broker.yaml
```

```sh
curl -Lo kourier.yaml https://github.com/knative/net-kourier/releases/download/knative-v1.15.0/kourier.yaml
```

```sh
# By default, the Kourier service is set to be of type LoadBalancer. On local machines, this type doesn’t work, so you’ll have to change the type to NodePort and add nodePort elements to the two listed ports.
apiVersion: v1
kind: Service
metadata:
  name: kourier
  namespace: kourier-system
  labels:
    networking.knative.dev/ingress-provider: kourier
spec:
  ports:
  - name: http2
    port: 80
    protocol: TCP
    targetPort: 8080
    nodePort: 31080
  - name: https
    port: 443
    protocol: TCP
    targetPort: 8443
    nodePort: 31443
  selector:
    app: 3scale-kourier-gateway
  type: NodePort

kubectl apply --filename kourier.yaml
```

```sh
kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'

# validate
kubectl describe configmap/config-network --namespace knative-serving

# expect

# ...
# ingress-class:
# ----
# kourier.ingress.networking.knative.dev
```

```sh
kubectl patch configmap/config-domain \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"127.0.0.1.sslip.io":""}}'

kubectl describe configmap/config-domain --namespace knative-serving
# ... (abbreviated for readability)
# Data
# ====
# 127.0.0.1.sslip.io:
# ----
# ...
```

```sh
kubectl get pods --namespace knative-serving

kubectl get pods --namespace kourier-system

kubectl --namespace kourier-system get service kourier

docker ps -a
```

```sh
cat > service.yaml <<EOF
apiVersion: serving.knative.dev/v1 # Current version of Knative
kind: Service
metadata:
  name: helloworld-go # The name of the app
  namespace: default # The namespace the app will use
spec:
  template:
    spec:
      containers:
        - image: ghcr.io/knative/helloworld-go:latest # The URL to the image of the app
          env:
            - name: TARGET # The environment variable printed out by the sample app
              value: "Hello Knative Serving is up and running with Kourier!!"
EOF

kubectl apply --filename service.yaml

kubectl get ksvc
# wait until READY True
```

```sh
curl -v http://helloworld-go.default.127.0.0.1.sslip.io
```

## ArgoCD

```sh
# file must exist
cat ~/.kube/config

kubectl create namespace argocd

kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl port-forward svc/argocd-server -n argocd 8080:443

argocd admin initial-password -n argocd

# login
argocd login localhost:8080 --insecure

# dummy app
argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace default

argocd app get guestbook

kubectl port-forward svc/guestbook-ui 8081:80
```

## My app

```sh
kubectl create namespace myapp

kubectl apply -f application.yaml
```

```sh
```

## Setup rabbitmq

```sh
docker run -d \
  --hostname rabbitmq \
  --name rabbitmq \
  -p 5672:5672 \
  -p 15672:15672 \
  -v $(pwd)/definitions1.json:/etc/rabbitmq/definitions.json:ro \
  -v $(pwd)/rabbitmq.conf:/etc/rabbitmq/rabbitmq.conf:ro \
  rabbitmq:4.3.1-management-alpine

# appuser3
# qwerty

```

## References

1. <https://knative.dev/blog/articles/set-up-a-local-knative-environment-with-kind/#step-1-setting-up-your-kubernetes-deployment-using-kind>
1. <https://kind.sigs.k8s.io/docs/user/quick-start/#creating-a-cluster>
1. <https://argo-cd.readthedocs.io/en/stable/getting_started/>
1. <https://gitlab.com/nanuchi/argocd-app-config/-/blob/main/application.yaml?ref_type=heads>
1. <https://knative.dev/docs/install/eventing/rabbitmq-install/#prerequisites>
