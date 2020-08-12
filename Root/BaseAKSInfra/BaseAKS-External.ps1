$var = Get-Content ($pwd.path +"/Root/1-Project-AKS-on-Azure/var.json") | ConvertFrom-Json

#create resource group
az group create -l $var.aks_location -n $var.aks_rg --verbose
#deploy aks
az aks create -n $var.aks_name -g $var.aks_rg --node-count 1 --enable-addons monitoring --generate-ssh-keys --verbose