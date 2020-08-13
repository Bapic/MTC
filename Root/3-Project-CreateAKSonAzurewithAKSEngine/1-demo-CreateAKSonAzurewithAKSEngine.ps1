git clone https://github.com/Bapic/CreateAKSonAzurewithAKSEngine.git
$context = az account show | convertfrom-json
$subscriptionId=$context.id
$location='eastus'
$resourceGroupName='k8sresgroup'
$dnsPrefix=$resourceGroupName
Write-host "Creating service principle" -ForegroundColor Green
$spn = az ad sp create-for-rbac --skip-assignment | convertfrom-json
 
$spnAppId= $spn.appid
$spnAppPassword=$spn.password
Write-host "Creating role assignments for the spn" -ForegroundColor Green
az role assignment create --role Contributor --assignee $spnAppId --scope $("/subscriptions/" + $subscriptionId)
$apimodel = ".\CreateAKSonAzurewithAKSEngine\Kubernetes.json"
Write-host "Deploying aks-engine" -ForegroundColor Green
aks-engine deploy --subscription-id $subscriptionId --resource-group $resourceGroupName --client-id $spnAppId  --client-secret $spnAppPassword  --dns-prefix $dnsPrefix --location $location --api-model $apimodel --force-overwrite
Write-host "To use kubectl to manage the kube cluster set environment variable `$env:KUBECONFIG = to absolute path of the json file stored at _output\resource group name\kubeconfig\" -ForegroundColor Green