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
kubectl get pods --namespace knative-serving

kubectl get pods --namespace kourier-system

kubectl --namespace kourier-system get service kourier

docker ps -a
```

```sh

```

```sh
```

```sh
```

```sh
```

```sh
```

## References

1. <https://knative.dev/blog/articles/set-up-a-local-knative-environment-with-kind/#step-1-setting-up-your-kubernetes-deployment-using-kind>
1. <https://kind.sigs.k8s.io/docs/user/quick-start/#creating-a-cluster>
