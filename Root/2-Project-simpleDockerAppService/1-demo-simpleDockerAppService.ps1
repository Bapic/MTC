# Read git hub username
$user = Read-Host "Enter Git hub user name"
# Read git hub access token
$pass = Read-Host "Enter Git hub pat token" -AsSecureString
# Read git hub mail id
$mail = Read-Host "Enter Git hub email address"
# Deployment region
$REGION_NAME="eastus"
# Resource group name
$RESOURCE_GROUP=$("DockerAppServiceRG-"+(get-random))
# App service name
$APP_NAME=$("simpleDockerAppService"+(Get-Random))
# Root git repo
$GITREPO="https://github.com/Bapic/simpleDockerAppService.git"
# Azure contianer registry name
$ACR_NAME=$("acr"+(Get-Random))
# Create RG
write-host "Creating resource group" -ForegroundColor Green
az group create --location $REGION_NAME --name $RESOURCE_GROUP
# Create app service plan
Write-Host "Creating App Service Plan" -ForegroundColor Green
az appservice plan create --name $APP_NAME --resource-group $RESOURCE_GROUP --location $REGION_NAME --is-linux --sku S1
# Create webapp
Write-Host "Creating Webapp" -ForegroundColor Green
az webapp create --name $APP_NAME --plan $APP_NAME --resource-group $RESOURCE_GROUP -i nginx
# Create acr
Write-Host "Creating Azure container registry" -ForegroundColor Green
az acr create --resource-group $RESOURCE_GROUP --location $REGION_NAME --name $ACR_NAME --sku Standard --admin-enabled true
# Check PS module
Write-Host "Checking PowerShellForGitHub Powershell module availability"
$mod = Get-Module PowerShellForGitHub
if (!$mod)
{
  Write-Host "PowerShellForGitHub Not available" -ForegroundColor Red
  Write-Host " Installing PowerShellForGitHub powershell module" -ForegroundColor Green
  Install-Module PowerShellForGitHub -Confirm:$false
}
# Create PSCreds for github auth
$cred = New-Object System.Management.Automation.PSCredential ($user, $pass)
# Set git context
Write-Host "Setting Git hub authentication" -ForegroundColor Green
Set-GitHubAuthentication -Credential $cred
# Create new git repo for code push
Write-Host "Creating git hub repo" -ForegroundColor Green
$repo = New-GitHubRepository -RepositoryName "DockerAppService"
# Set git global config
Write-Host "Setting Git global config" -ForegroundColor Green
git config --global user.email $mail
git config --global user.name $user
# Clone repo
Write-Host "cloning remote git repo" -ForegroundColor Green
git clone https://github.com/Bapic/simpleDockerAppService.git
cd simpleDockerAppService
# Remove remote origin
git remote rm origin
# Add custom origin
git remote add origin $repo.clone_url
# Initialize repo
git init
# Add files for commit
git add .
# Commit changes
git commit -m "read to push"
# push To Master
Write-Host "Pushing code to personal git repo" -ForegroundColor Green
git push -u origin master

# Set container settings in webapp
# Get acr username
$acr_username = az acr credential show --name $ACR_NAME -g $RESOURCE_GROUP --query username -o tsv
# Get acr password
$acr_password = az acr credential show --name $ACR_NAME -g $RESOURCE_GROUP --query passwords[0].value -o tsv
# Update webapp config to user acr
Write-Host "Updating web app container settings" -ForegroundColor Green
az webapp config container set --docker-registry-server-password $acr_password --docker-registry-server-url $("https://" +$acr_username + ".azurecr.io") --docker-registry-server-user $acr_username --name $APP_NAME --resource-group $RESOURCE_GROUP
# Enable continious deployment
Write-Host "Enabling continious container deployment" -ForegroundColor Green
az webapp deployment container config --enable-cd true -n $APP_NAME -g $RESOURCE_GROUP
write-host "Now, manually configure the Deployment Source as Github with Azure DevOps pipelines with continuous deployment"
write-host "Make changes to the App files txt, push the changes and that should reflect on the site instantly"