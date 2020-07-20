#AKS/rg name
$name="sampleAKSonAzure001"
#Deployment region
$location="eastus"
#create resource group
az group create -l eastus -n $name --verbose
#deploy aks
az aks create -n $name -g $name --node-count 1 --enable-addons monitoring --generate-ssh-keys --verbose