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

$pwd = pwd
$jsonpath = $($pwd.path + "\_output\" + $resourceGroupName + "\kubeconfig\kubeconfig." + $location +".json")
Write-host "Setting `$env:KUBECONFIG=$jsonpath" -ForegroundColor Green
$env:KUBECONFIG=$jsonpath
Write-host "Get cluster info" -ForegroundColor Green
kubectl cluster-info
Write-host "Get pods" -ForegroundColor Green
kubectl get pods
Write-host "Get service" -ForegroundColor Green
kubectl get svc
Write-host "Get nodes" -ForegroundColor Green
kubectl get nodes