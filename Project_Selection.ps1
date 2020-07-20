Write-Host = "Please select the project no" -ForegroundColor Green
(Get-ChildItem -Path .\Root).Name | ?{$_ -like "*-project*"}
$choice = Read-Host ":"
Write-Host = "Please select the demo to be deployed" -ForegroundColor Green
$Project_name = (Get-ChildItem (".\Root\" + $choice + "-Project*")).name
(Get-ChildItem (".\Root\" + $Project_name)).Name | ?{$_ -like "*-demo*"}
$project = Read-Host ":"

$script_path=(Get-ChildItem (".\Root\" + $Project_name +"\" + $project + "-demo*")).FullName
. $script_path