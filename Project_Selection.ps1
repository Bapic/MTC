Write-Host = "Please select the project no"
(Get-ChildItem -Path .\Root).Name
$choice = Read-Host ":"
Write-Host = "Please select the demo to be deployed"
$Project_name = (Get-ChildItem (".\Root\" + $choice + "-Project*")).name
Write-Host = "Please select the demo to be deployed"
(Get-ChildItem (".\Root\" + $Project_name)).Name | ?{$_ -like "*-demo*"}
$project = Read-Host ":"

$script_path=(Get-ChildItem (".\Root\" + $Project_name +"\" + $project + "-demo*")).FullName
. $script_path