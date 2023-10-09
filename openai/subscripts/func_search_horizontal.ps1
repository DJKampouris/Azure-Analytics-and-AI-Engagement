az login

#for powershell...
Connect-AzAccount -DeviceCode
$starttime = get-date
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
$func_search_horizontal = "func-openai-search-horizontal-$suffix"
$searchName = "srch-openai-$suffix"
$openAIResource = "openAIservice$concatString"
if($openAIResource.length -gt 24)
{
$openAIResource = $openAIResource.substring(0,24)
}

$storage_account_key = (Get-AzStorageAccountKey -ResourceGroupName $rgName -AccountName $dataLakeAccountName)[0].Value

#retirieving primary key
$openAIPrimaryKey = az cognitiveservices account keys list -n $openAIResource -g $rgName | jq -r .key1

# Get search primary admin key
Install-Module -Name Az.Search
$adminKeyPair = Get-AzSearchAdminKeyPair -ResourceGroupName $rgName -ServiceName $searchName
$searchServicePrimaryAdminKey = $adminKeyPair.Primary

$urlMainWebAppCors = "https://" + $app_openai_name + ".azurewebsites.net"
$cors = az functionapp cors add -g $rgName -n $func_search_horizontal --allowed-origins $urlMainWebAppCors

## function search horizontal
# Get search primary admin key

(Get-Content -path func-search-horizontal/function_app.py -Raw) | Foreach-Object { $_ `
    -replace '#AZURE_STORAGE_ACCOUNT#', $dataLakeAccountName`
    -replace '#AZURE_STORAGE_CONTAINER#', "knowledge-base-responsibleai"`
    -replace '#AZURE_SEARCH_SERVICE#', $searchName`
    -replace '#AZURE_SEARCH_INDEX#', "prod-responsibleai-search"`
    -replace '#AZURE_OPENAI_SERVICE#', $openAIResource`
    -replace '#AZURE_OPENAI_TEXT_DAVINCI_DEPLOYMENT#', "text-davinci-003"`
    -replace '#AZURE_OPENAI_GPT_TURBO_DEPLOYMENT#', "gpt-35-turbo"`
    -replace '#AZURE_OPENAI_SERVICE_KEY#', $openAIPrimaryKey`
    -replace '#AZURE_SEARCH_SERVICE_KEY#', $searchServicePrimaryAdminKey`
    -replace '#AZURE_SEARCH_SERVICE_PROD_KEY#', $searchServicePrimaryAdminKey`
    -replace '#AZURE_STORAGE_ACCOUNT_KEY#', $storage_account_key`
} | Set-Content -Path func-search-horizontal/function_app.py

$configSH = az functionapp config appsettings set --name $func_search_horizontal --resource-group $rgName --settings AZURE_STORAGE_ACCOUNT=$dataLakeAccountName
$configSH = az functionapp config appsettings set --name $func_search_horizontal --resource-group $rgName --settings AZURE_STORAGE_CONTAINER="knowledge-base-responsibleai"
$configSH = az functionapp config appsettings set --name $func_search_horizontal --resource-group $rgName --settings AZURE_SEARCH_SERVICE=$searchName
$configSH = az functionapp config appsettings set --name $func_search_horizontal --resource-group $rgName --settings AZURE_SEARCH_INDEX="prod-responsibleai-search"
$configSH = az functionapp config appsettings set --name $func_search_horizontal --resource-group $rgName --settings AZURE_OPENAI_SERVICE=$openAIResource
$configSH = az functionapp config appsettings set --name $func_search_horizontal --resource-group $rgName --settings AZURE_OPENAI_GPT_TURBO_DEPLOYMENT="gpt-35-turbo"
$configSH = az functionapp config appsettings set --name $func_search_horizontal --resource-group $rgName --settings AZURE_OPENAI_TEXT_DAVINCI_DEPLOYMENT="text-davinci-003"
$configSH = az functionapp config appsettings set --name $func_search_horizontal --resource-group $rgName --settings AZURE_OPENAI_SERVICE_KEY=$openAIPrimaryKey
$configSH = az functionapp config appsettings set --name $func_search_horizontal --resource-group $rgName --settings AZURE_SEARCH_SERVICE_KEY=$searchServicePrimaryAdminKey
$configSH = az functionapp config appsettings set --name $func_search_horizontal --resource-group $rgName --settings AZURE_SEARCH_SERVICE_PROD_KEY=$searchServicePrimaryAdminKey
$configSH = az functionapp config appsettings set --name $func_search_horizontal --resource-group $rgName --settings AZURE_STORAGE_ACCOUNT_KEY=$storage_account_key
$configSH = az functionapp config appsettings set --name $func_search_horizontal --resource-group $rgName --settings KB_FIELDS_CONTENT="content"
$configSH = az functionapp config appsettings set --name $func_search_horizontal --resource-group $rgName --settings KB_FIELDS_CATEGORY="category"
$configSH = az functionapp config appsettings set --name $func_search_horizontal --resource-group $rgName --settings KB_FIELDS_SOURCEPAGE="sourcepage"

cd ../func-search-horizontal
func azure functionapp publish $func_search_horizontal --force
# az webapp up --resource-group $rgName --name $func_search_horizontal --plan $asp_search_horizontal --location $Region --sku "B1"
cd ../subscripts
Start-Sleep -s 20
az webapp restart  --name $func_search_horizontal --resource-group $rgName
