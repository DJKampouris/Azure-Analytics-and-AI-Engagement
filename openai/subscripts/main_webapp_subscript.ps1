function RefreshTokens() {
    #Copy external blob content
    $global:powerbitoken = ((az account get-access-token --resource https://analysis.windows.net/powerbi/api) | ConvertFrom-Json).accessToken
    $global:synapseToken = ((az account get-access-token --resource https://dev.azuresynapse.net) | ConvertFrom-Json).accessToken
    $global:graphToken = ((az account get-access-token --resource https://graph.microsoft.com) | ConvertFrom-Json).accessToken
    $global:managementToken = ((az account get-access-token --resource https://management.azure.com) | ConvertFrom-Json).accessToken
    $global:purviewToken = ((az account get-access-token --resource https://purview.azure.net) | ConvertFrom-Json).accessToken
}

function ReplaceTokensInFile($ht, $filePath) {
    $template = Get-Content -Raw -Path $filePath
    
    foreach ($paramName in $ht.Keys) {
        $template = $template.Replace($paramName, $ht[$paramName])
    }

    return $template;
}


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
$wsId =  (Get-AzResourceGroup -Name $rgName).Tags["WsId"] 
$suffix = "$random-$init"
$concatString = "$init$random"
$dataLakeAccountName = "stopenai$concatString"
if($dataLakeAccountName.length -gt 24)
{
$dataLakeAccountName = $dataLakeAccountName.substring(0,24)
}
$func_campaign_generation = "func-campaign-generator-$suffix"
$func_search_horizontal = "func-openai-search-horizontal-$suffix"
$func_recommend_images = "func-recommend-images-$suffix"
$func_regenerate_dalle = "func-regenerate-dalle-$suffix"
$func_pdf_indexer = "func-pdf-indexer-$suffix"
$app_openai_name = "app-open-ai-$suffix"
$tenantId = (Get-AzContext).Tenant.Id
$openAIResource = "openAIservice$concatString"
if($openAIResource.length -gt 24)
{
$openAIResource = $openAIResource.substring(0,24)
}

#retrieving openai endpoint
$openAIEndpoint = az cognitiveservices account show -n $openAIResource -g $rgName | jq -r .properties.endpoint

#retirieving primary key
$openAIPrimaryKey = az cognitiveservices account keys list -n $openAIResource -g $rgName | jq -r .key1

#Web app
Add-Content log.txt "------deploy poc web app------"
Write-Host  "-----------------Deploy web app---------------"
RefreshTokens

$spname = "Open AI $init"

$app = az ad app create --display-name $spname | ConvertFrom-Json
$appId = $app.appId

$mainAppCredential = az ad app credential reset --id $appId | ConvertFrom-Json
$clientsecpwd = $mainAppCredential.password

az ad sp create --id $appId | Out-Null    
$sp = az ad sp show --id $appId --query "id" -o tsv
start-sleep -s 20

#https://docs.microsoft.com/en-us/power-bi/developer/embedded/embed-service-principal
#Allow service principals to user PowerBI APIS must be enabled - https://app.powerbi.com/admin-portal/tenantSettings?language=en-U
#add PowerBI App to workspace as an admin to group
RefreshTokens
$url = "https://api.powerbi.com/v1.0/myorg/groups";
$result = Invoke-WebRequest -Uri $url -Method GET -ContentType "application/json" -Headers @{ Authorization = "Bearer $powerbitoken" } -ea SilentlyContinue;
$homeCluster = $result.Headers["home-cluster-uri"]
#$homeCluser = "https://wabi-west-us-redirect.analysis.windows.net";

RefreshTokens
$url = "$homeCluster/metadata/tenantsettings"
$post = "{`"featureSwitches`":[{`"switchId`":306,`"switchName`":`"ServicePrincipalAccess`",`"isEnabled`":true,`"isGranular`":true,`"allowedSecurityGroups`":[],`"deniedSecurityGroups`":[]}],`"properties`":[{`"tenantSettingName`":`"ServicePrincipalAccess`",`"properties`":{`"HideServicePrincipalsNotification`":`"false`"}}]}"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $powerbiToken")
$headers.Add("X-PowerBI-User-Admin", "true")
#$result = Invoke-RestMethod -Uri $url -Method PUT -body $post -ContentType "application/json" -Headers $headers -ea SilentlyContinue;

#add PowerBI App to workspace as an admin to group
RefreshTokens
$url = "https://api.powerbi.com/v1.0/myorg/groups/$wsid/users";
$post = "{
`"identifier`":`"$($sp)`",
`"groupUserAccessRight`":`"Admin`",
`"principalType`":`"App`"
}";

$result = Invoke-RestMethod -Uri $url -Method POST -body $post -ContentType "application/json" -Headers @{ Authorization = "Bearer $powerbitoken" } -ea SilentlyContinue;

#get the power bi app...
$powerBIApp = Get-AzADServicePrincipal -DisplayNameBeginsWith "Power BI Service"
$powerBiAppId = $powerBIApp.Id;

#setup powerBI app...
RefreshTokens
$url = "https://graph.microsoft.com/beta/OAuth2PermissionGrants";
$post = "{
`"clientId`":`"$appId`",
`"consentType`":`"AllPrincipals`",
`"resourceId`":`"$powerBiAppId`",
`"scope`":`"Dataset.ReadWrite.All Dashboard.Read.All Report.Read.All Group.Read Group.Read.All Content.Create Metadata.View_Any Dataset.Read.All Data.Alter_Any`",
`"expiryTime`":`"2021-03-29T14:35:32.4943409+03:00`",
`"startTime`":`"2020-03-29T14:35:32.4933413+03:00`"
}";

$result = Invoke-RestMethod -Uri $url -Method GET -ContentType "application/json" -Headers @{ Authorization = "Bearer $graphtoken" } -ea SilentlyContinue;

#setup powerBI app...
RefreshTokens
$url = "https://graph.microsoft.com/beta/OAuth2PermissionGrants";
$post = "{
`"clientId`":`"$appId`",
`"consentType`":`"AllPrincipals`",
`"resourceId`":`"$powerBiAppId`",
`"scope`":`"User.Read Directory.AccessAsUser.All`",
`"expiryTime`":`"2021-03-29T14:35:32.4943409+03:00`",
`"startTime`":`"2020-03-29T14:35:32.4933413+03:00`"
}";

$result = Invoke-RestMethod -Uri $url -Method GET -ContentType "application/json" -Headers @{ Authorization = "Bearer $graphtoken" } -ea SilentlyContinue;

# #retrieving cognitive service endpoint
# $cognitiveEndpoint = az cognitiveservices account show -n $cognitive_service_name -g $rgName | jq -r .properties.endpoint

# #retirieving cognitive service key
# $cognitivePrimaryKey = az cognitiveservices account keys list -n $cognitive_service_name -g $rgName | jq -r .key1

(Get-Content -path app-contoso-openai/appsettings.json -Raw) | Foreach-Object { $_ `
        -replace '#WORKSPACE_ID#', $wsId`
        -replace '#APP_ID#', $appId`
        -replace '#APP_SECRET#', $clientsecpwd`
        -replace '#TENANT_ID#', $tenantId`
} | Set-Content -Path app-contoso-openai/appsettings.json

$filepath = "./app-contoso-openai/wwwroot/config.js"
$itemTemplate = Get-Content -Path $filepath
$item = $itemTemplate.Replace("#STORAGE_ACCOUNT#", $dataLakeAccountName).Replace("#SERVER_NAME#", $app_openai_name)
Set-Content -Path $filepath -Value $item

RefreshTokens
$url = "https://api.powerbi.com/v1.0/myorg/groups/$wsId/reports";
$reportList = Invoke-RestMethod -Uri $url -Method GET -Headers @{ Authorization = "Bearer $powerbitoken" };
$reportList = $reportList.Value

#update all th report ids in the poc web app...
$ht = new-object system.collections.hashtable   
# $ht.add("#Bing_Map_Key#", "AhBNZSn-fKVSNUE5xYFbW_qajVAZwWYc8OoSHlH8nmchGuDI6ykzYjrtbwuNSrR8")
$ht.add("#World Map OpenAI#", $($reportList | where { $_.name -eq "World Map OpenAI" }).id)
$ht.add("#GM Call Center Report After OpenAI#", $($reportList | where { $_.name -eq "GM Call Center Report After OpenAI" }).id)
$ht.add("#GM Call Center Report Before OpenAI#", $($reportList | where { $_.name -eq "GM Call Center Report Before OpenAI" }).id)
$ht.add("#Retail Group CEO KPI OpenAI#", $($reportList | where { $_.name -eq "Retail Group CEO KPI OpenAI" }).id)

$filePath = "./app-contoso-openai/wwwroot/config.js";
Set-Content $filePath $(ReplaceTokensInFile $ht $filePath)

$Config_pdfUploadApi = "https://" + $func_pdf_indexer + ".azurewebsites.net/api/pdfindexer"
$config = az webapp config appsettings set -g $rgName -n $app_openai_name --settings Config__pdfUploadApi=$Config_pdfUploadApi

$Config_florenceAdApi = "https://" + $func_campaign_generation + ".azurewebsites.net/api/campaign_generation"
$config = az webapp config appsettings set -g $rgName -n $app_openai_name --settings Config__florenceAdApi=$Config_florenceAdApi

$Config_florenceDallEApi = "https://" + $func_recommend_images + ".azurewebsites.net/api/recommendFromImage_V2"
$config = az webapp config appsettings set -g $rgName -n $app_openai_name --settings Config__florenceDallEApi=$Config_florenceDallEApi

$Config_dalleRegenerateAPI = "https://" + $func_regenerate_dalle + ".azurewebsites.net/api/regenerate-dalle"
$config = az webapp config appsettings set -g $rgName -n $app_openai_name --settings Config__dalleRegenerateAPI=$Config_dalleRegenerateAPI

$Config_summarizeConversationAPI = $openAIEndpoint + "openai/deployments/text-davinci-003/completions?api-version=2022-12-01"
$config = az webapp config appsettings set -g $rgName -n $app_openai_name --settings Config__summarizeConversationAPI=$Config_summarizeConversationAPI

$Config_summarizeConversationAPIKey = $openAIPrimaryKey
$config = az webapp config appsettings set -g $rgName -n $app_openai_name --settings Config__summarizeConversationAPIKey=$Config_summarizeConversationAPIKey

$Config_endPointURL = "https://" + $func_search_horizontal + ".azurewebsites.net/api"
$config = az webapp config appsettings set -g $rgName -n $app_openai_name --settings Config__endPointURL=$Config_endPointURL

Compress-Archive -Path "./app-contoso-openai/*" -DestinationPath "./app-contoso-openai.zip" -Update

az webapp stop --name $app_openai_name --resource-group $rgName
try {
    az webapp deployment source config-zip --resource-group $rgName --name $app_openai_name --src "./app-contoso-openai.zip"
}
catch {
}

az webapp start --name $app_openai_name --resource-group $rgName
