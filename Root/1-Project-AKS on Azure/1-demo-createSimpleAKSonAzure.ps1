#AKS/rg name
$name="sampleAKSonAzure001"
#Deployment region
$location="eastus"

$aks = Get-AzAks -Name $name -ResourceGroupName $name -ErrorAction SilentlyContinue
if ($aks -eq $null)
{
. .\Root\BaseAKSInfra\BaseAKS-External.ps1
}
#get aks credentials
az aks get-credentials -n $name -g $name --overwrite-existing --verbose
#Show current Context
Write-Host -ForegroundColor Green "Current Context"
kubectl config get-contexts
#show kube svc
Write-Host -ForegroundColor Green "AKS Deployed Services"
kubectl get svc
#show nodes
Write-Host -ForegroundColor Green "AKS Nodes"
kubectl get nodes
#show pods
Write-Host -ForegroundColor Green "AKS running Pods"
kubectl get pods -A
#show namespace
Write-Host -ForegroundColor Green "AKS Namespaces"
kubectl get ns --show-labels
#show cluster info
Write-Host -ForegroundColor Green "AKS Cluster-info"
kubectl cluster-info
#deploy voting app
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
Write-Host -ForegroundColor Green "Deploying voting application ..."
$vote | kubectl apply -f -
#show deployments
Write-Host -ForegroundColor Green "AKS Deployments"
kubectl get deploy -o wide
#get service ip
Write-Host "Service IP for voting App" -ForegroundColor Green
kubectl get service azure-vote-front -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'
