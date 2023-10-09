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
$forms_open_ai_name = "form-openai-$suffix"    
$dataLakeAccountName = "stopenai$concatString"
if($dataLakeAccountName.length -gt 24)
{
$dataLakeAccountName = $dataLakeAccountName.substring(0,24)
}
$func_pdf_indexer = "func-pdf-indexer-$suffix"
$app_openai_name = "app-open-ai-$suffix"
$searchName = "srch-openai-$suffix"
$openAIResource = "openAIservice$concatString"
if($openAIResource.length -gt 24)
{
$openAIResource = $openAIResource.substring(0,24)
}

$storage_account_key = (Get-AzStorageAccountKey -ResourceGroupName $rgName -AccountName $dataLakeAccountName)[0].Value

$forms_open_ai_keys = Get-AzCognitiveServicesAccountKey -ResourceGroupName $rgName -name $forms_open_ai_name

$forms_openai_key = $forms_open_ai_keys.Key1

# Get search primary admin key
Install-Module -Name Az.Search
$adminKeyPair = Get-AzSearchAdminKeyPair -ResourceGroupName $rgName -ServiceName $searchName
$searchServicePrimaryAdminKey = $adminKeyPair.Primary

## cors updation in function app
$urlMainWebAppCors = "https://" + $app_openai_name + ".azurewebsites.net"
$cors = az functionapp cors add -g $rgName -n $func_pdf_indexer --allowed-origins $urlMainWebAppCors

## function pdf indexer
(Get-Content -path func-pdf-indexer/delete.py -Raw) | Foreach-Object { $_ `
    -replace '#SEARCH_SERVICE_NAME#', $searchName`
    -replace '#SEARCH_SERVICE_KEY#', $searchServicePrimaryAdminKey`
    -replace '#STORAGE_ACCOUNT_KEY#', $storage_account_key`
    -replace '#STORAGE_ACCOUNT_NAME#', $dataLakeAccountName`
    -replace '#FORM_RECOGNIZER_KEY#', $forms_open_ai_keys.Key1`
} | Set-Content -Path func-pdf-indexer/delete.py

## function pdf indexer
$configSO = az functionapp config appsettings set --name $func_pdf_indexer --resource-group $rgName --settings SEARCH_SERVICE_NAME=$searchName
$configSO = az functionapp config appsettings set --name $func_pdf_indexer --resource-group $rgName --settings SEARCH_SERVICE_KEY=$searchServicePrimaryAdminKey
$configSO = az functionapp config appsettings set --name $func_pdf_indexer --resource-group $rgName --settings STORAGE_ACCOUNT_KEY=$storage_account_key
$configSO = az functionapp config appsettings set --name $func_pdf_indexer --resource-group $rgName --settings STORAGE_ACCOUNT_NAME=$dataLakeAccountName
$configSO = az functionapp config appsettings set --name $func_pdf_indexer --resource-group $rgName --settings FORM_RECOGNIZER_KEY=$forms_openai_key
$configSO = az functionapp config appsettings set --name $func_pdf_indexer --resource-group $rgName --settings FormRecognizerService=$forms_open_ai_name
$configSO = az functionapp config appsettings set --name $func_pdf_indexer --resource-group $rgName --settings form_recognizer_header="azure-search-chat-demo/1.0.0"

cd ../func-pdf-indexer
func azure functionapp publish $func_pdf_indexer --force
# az webapp up --resource-group $rgName --name $func_pdf_indexer --plan $asp_pdf_indexer --location $Region --sku "B1"
cd ../subscripts
Start-Sleep -s 20
az webapp restart  --name $func_pdf_indexer --resource-group $rgName
