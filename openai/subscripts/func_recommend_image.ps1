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
$func_recommend_images = "func-recommend-images-$suffix"
$app_openai_name = "app-open-ai-$suffix"
$cognitive_service_name = "cog-openai-$suffix"
$openAIResource = "openAIservice$concatString"
if($openAIResource.length -gt 24)
{
$openAIResource = $openAIResource.substring(0,24)
}

$storage_account_key = (Get-AzStorageAccountKey -ResourceGroupName $rgName -AccountName $dataLakeAccountName)[0].Value

#retrieving openai endpoint
$openAIEndpoint = az cognitiveservices account show -n $openAIResource -g $rgName | jq -r .properties.endpoint

#retirieving primary key
$openAIPrimaryKey = az cognitiveservices account keys list -n $openAIResource -g $rgName | jq -r .key1

#retrieving cognitive service endpoint
$cognitiveEndpoint = az cognitiveservices account show -n $cognitive_service_name -g $rgName | jq -r .properties.endpoint

#retirieving cognitive service key
$cognitivePrimaryKey = az cognitiveservices account keys list -n $cognitive_service_name -g $rgName | jq -r .key1

$urlMainWebAppCors = "https://" + $app_openai_name + ".azurewebsites.net"
$cors = az functionapp cors add -g $rgName -n $func_recommend_images --allowed-origins $urlMainWebAppCors

## function recommend image
$connect_str = "DefaultEndpointsProtocol=https;AccountName=" + $dataLakeAccountName + ";AccountKey=" + $storage_account_key
    
(Get-Content -path func-recommend-image/function_app.py -Raw) | Foreach-Object { $_ `
    -replace '#AZURE_OPENAI_KEY#', $openAIPrimaryKey`
    -replace '#AZURE_COGNITIVE_KEY#', $cognitivePrimaryKey`
    -replace '#OPENAI_ENDPOINT#', $openAIEndpoint`
    -replace '#STORAGE_ACCOUNT_NAME#', $dataLakeAccountName`
    -replace '#STORAGE_CONNECTION_STRING#', $connect_str`
    -replace '#STORAGE_ACCOUNT_KEY#', $storage_account_key`
    -replace '#COGNITIVE_SERVICE_ENDPOINT#', $cognitiveEndpoint`
} | Set-Content -Path func-recommend-image/function_app.py

(Get-Content -path func-recommend-image/image_generation.py -Raw) | Foreach-Object { $_ `
    -replace '#OPENAI_PRIMARY_KEY#', $openAIPrimaryKey`
    -replace '#OPENAI_API_ENDPOINT#', $openAIEndpoint`
} | Set-Content -Path func-recommend-image/image_generation.py

$configRI = az functionapp config appsettings set --name $func_recommend_images --resource-group $rgName --settings STORAGE_ACCOUNT=$dataLakeAccountName
$configRI = az functionapp config appsettings set --name $func_recommend_images --resource-group $rgName --settings STORAGE_ACCOUNT_KEY=$storage_account_key
$configRI = az functionapp config appsettings set --name $func_recommend_images --resource-group $rgName --settings STORAGE_CONTAINER="vouquahyaeyiepo"
$configRI = az functionapp config appsettings set --name $func_recommend_images --resource-group $rgName --settings ENGINE="gpt-35-turbo"
$configRI = az functionapp config appsettings set --name $func_recommend_images --resource-group $rgName --settings COGNITIVE_SERVICE_API=$cognitiveEndpoint
$configRI = az functionapp config appsettings set --name $func_recommend_images --resource-group $rgName --settings container_name="data2"
$configRI = az functionapp config appsettings set --name $func_recommend_images --resource-group $rgName --settings cognitive_key=$cognitivePrimaryKey
$configRI = az functionapp config appsettings set --name $func_recommend_images --resource-group $rgName --settings connect_str=$connect_str
$configRI = az functionapp config appsettings set --name $func_recommend_images --resource-group $rgName --settings OPENAI_API_ENDPOINT=$openAIEndpoint
$configRI = az functionapp config appsettings set --name $func_recommend_images --resource-group $rgName --settings OPENAI_API_KEY=$openAIPrimaryKey
$configRI = az functionapp config appsettings set --name $func_recommend_images --resource-group $rgName --settings openai_api_type="azure"

cd ../func-recommend-image
func azure functionapp publish $func_recommend_images
# az webapp up --resource-group $rgName --name $func_recommend_images --plan $asp_recommend_images --location $Region --sku "B1"
cd ../subscripts
Start-Sleep -s 20
az webapp restart  --name $func_recommend_images --resource-group $rgName
