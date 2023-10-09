az login

#for powershell...
Connect-AzAccount -DeviceCode

$subs = Get-AzSubscription | Select-Object -ExpandProperty Name
if ($subs.GetType().IsArray -and $subs.length -gt 1) {
    $subOptions = [System.Collections.ArrayList]::new()
    for ($subIdx = 0; $subIdx -lt $subs.length; $subIdx++) {
        $opt = New-Object System.Management.Automation.Host.ChoiceDescription "$($subs[$subIdx])", "Selects the $($subs[$subIdx]) subscription."   
        $subOptions.Add($opt)
    }
    $selectedSubIdx = $host.ui.PromptForChoice('Enter the desired Azure Subscription for this lab', 'Copy and paste the name of the subscription to make your choice.', $subOptions.ToArray(), 0)
    $selectedSubName = $subs[$selectedSubIdx]
    Write-Host "Selecting the subscription : $selectedSubName "
    $title = 'Subscription selection'
    $question = 'Are you sure you want to select this subscription for this lab?'
    $choices = '&Yes', '&No'
    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
    if ($decision -eq 0) {
        Select-AzSubscription -SubscriptionName $selectedSubName
        az account set --subscription $selectedSubName
    }
    else {
        $selectedSubIdx = $host.ui.PromptForChoice('Enter the desired Azure Subscription for this lab', 'Copy and paste the name of the subscription to make your choice.', $subOptions.ToArray(), 0)
        $selectedSubName = $subs[$selectedSubIdx]
        Write-Host "Selecting the subscription : $selectedSubName "
        Select-AzSubscription -SubscriptionName $selectedSubName
        az account set --subscription $selectedSubName
    }
}

$rgName = read-host "Enter the resource Group Name";
$Region = (Get-AzResourceGroup -Name $rgName).Location
$init =  (Get-AzResourceGroup -Name $rgName).Tags["DeploymentId"]
$random =  (Get-AzResourceGroup -Name $rgName).Tags["UniqueId"] 
$suffix = "$random-$init"
$concatString = "$init$random"
$dataLakeAccountName = "stopenai$concatString"
if($dataLakeAccountName.length -gt 24)
{
$dataLakeAccountName = $dataLakeAccountName.substring(0,24)
}
$func_campaign_generation = "func-campaign-generator-$suffix"
$app_openai_name = "app-open-ai-$suffix"
$openAIResource = "openAIservice$concatString"
if($openAIResource.length -gt 24)
{
$openAIResource = $openAIResource.substring(0,24)
}

#retirieving primary key
$openAIPrimaryKey = az cognitiveservices account keys list -n $openAIResource -g $rgName | jq -r .key1

$urlMainWebAppCors = "https://" + $app_openai_name + ".azurewebsites.net"
$cors = az functionapp cors add -g $rgName -n $func_campaign_generation --allowed-origins $urlMainWebAppCors

## function campaign generation
(Get-Content -path func-campaign-generation/function_app.py -Raw) | Foreach-Object { $_ `
    -replace '#OPENAI_SERVICE_NAME#', $openAIResource`
    -replace '#OPENAI_PRIMARY_KEY#', $openAIPrimaryKey`
    -replace '#OPENAI_MODEL_DEPLOYMENT_NAME#', "text-davinci-003"`
    -replace '#OPENAI_MODEL_ENGINE_NAME#', "text-davinci-003"`
} | Set-Content -Path func-campaign-generation/function_app.py

$configCG = az functionapp config appsettings set --name $func_campaign_generation --resource-group $rgName --settings AZURE_OPENAI_MODEL_DEPLOYMENT="text-davinci-003"
$configCG = az functionapp config appsettings set --name $func_campaign_generation --resource-group $rgName --settings AZURE_OPENAI_SERVICE=$openAIResource
$configCG = az functionapp config appsettings set --name $func_campaign_generation --resource-group $rgName --settings AZURE_OPENAI_SERVICE_KEY=$openAIPrimaryKey
$configCG = az functionapp config appsettings set --name $func_campaign_generation --resource-group $rgName --settings AZURE_OPENAI_MODEL_ENGINE_DEPLOYMENT="text-davinci-003"
$configCG = az functionapp config appsettings set --name $func_campaign_generation --resource-group $rgName --settings AzureWebJobsFeatureFlags="EnableWorkerIndexing"

cd ../func-campaign-generation
func azure functionapp publish $func_campaign_generation
# az webapp up --resource-group $rgName --name $func_campaign_generation --plan $asp_campaign_generation --location $Region --sku "B1"
cd ../subscripts
Start-Sleep -s 20
az webapp restart  --name $func_campaign_generation --resource-group $rgName
