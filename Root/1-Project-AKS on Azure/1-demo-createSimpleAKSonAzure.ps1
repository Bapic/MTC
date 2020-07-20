$name="sampleAKSonAzure01"
$location="eastus"
az group create -l eastus -n $name
az aks create -n $name -g $name --node-count 1 --enable-addons monitoring --generate-ssh-keys
az aks get-credentials -n $name -g $name
set-content clusterinfo.txt (kubectl config get-contexts)
add-content clusterinfo.txt (kubectl get svc)
add-content clusterinfo.txt (kubectl get nodes)
add-content clusterinfo.txt (kubectl get pods)
add-content clusterinfo.txt (kubectl get ns --show-labels)
add-content clusterinfo.txt (kubectl -n cluster-config get deploy  -o wide)
add-content clusterinfo.txt (kubectl cluster-info)
code clusterinfo.txt
$vote = @"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-back
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-back
  template:
    metadata:
      labels:
        app: azure-vote-back
    spec:
      nodeSelector:
        "beta.kubernetes.io/os": linux
      containers:
      - name: azure-vote-back
        image: redis
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
        ports:
        - containerPort: 6379
          name: redis
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-back
spec:
  ports:
  - port: 6379
  selector:
    app: azure-vote-back
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-front
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-front
  template:
    metadata:
      labels:
        app: azure-vote-front
    spec:
      nodeSelector:
        "beta.kubernetes.io/os": linux
      containers:
      - name: azure-vote-front
        image: microsoft/azure-vote-front:v1
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
        ports:
        - containerPort: 80
        env:
        - name: REDIS
          value: "azure-vote-back"
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-front
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: azure-vote-front
"@
$vote | kubectl apply -f -
