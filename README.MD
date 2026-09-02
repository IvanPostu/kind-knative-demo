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
