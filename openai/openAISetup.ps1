$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "I accept the license agreement."
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "I do not accept and wish to stop execution."
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$title = "Agreement"
$message = "By typing [Y], I hereby confirm that I have read the license ( available at https://github.com/microsoft/Azure-Analytics-and-AI-Engagement/blob/main/license.md ) and disclaimers ( available at https://github.com/microsoft/Azure-Analytics-and-AI-Engagement/blob/main/README.md ) and hereby accept the terms of the license and agree that the terms and conditions set forth therein govern my use of the code made available hereunder. (Type [Y] for Yes or [N] for No and press enter)"
$result = $host.ui.PromptForChoice($title, $message, $options, 1)
if ($result -eq 1) {
    write-host "Thank you. Please ensure you delete the resources created with template to avoid further cost implications."
}
else {
    function RefreshTokens() {
        #Copy external blob content
        $global:powerbitoken = ((az account get-access-token --resource https://analysis.windows.net/powerbi/api) | ConvertFrom-Json).accessToken
        $global:synapseToken = ((az account get-access-token --resource https://dev.azuresynapse.net) | ConvertFrom-Json).accessToken
        $global:graphToken = ((az account get-access-token --resource https://graph.microsoft.com) | ConvertFrom-Json).accessToken
        $global:managementToken = ((az account get-access-token --resource https://management.azure.com) | ConvertFrom-Json).accessToken
        $global:purviewToken = ((az account get-access-token --resource https://purview.azure.net) | ConvertFrom-Json).accessToken
    }

    function Check-HttpRedirect($uri) {
        $httpReq = [system.net.HttpWebRequest]::Create($uri)
        $httpReq.Accept = "text/html, application/xhtml+xml, */*"
        $httpReq.method = "GET"   
        $httpReq.AllowAutoRedirect = $false;
    
        #use them all...
        #[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Ssl3 -bor [System.Net.SecurityProtocolType]::Tls;

        $global:httpCode = -1;
    
        $response = "";            

        try {
            $res = $httpReq.GetResponse();

            $statusCode = $res.StatusCode.ToString();
            $global:httpCode = [int]$res.StatusCode;
            $cookieC = $res.Cookies;
            $resHeaders = $res.Headers;  
            $global:rescontentLength = $res.ContentLength;
            $global:location = $null;
                                
            try {
                $global:location = $res.Headers["Location"].ToString();
                return $global:location;
            }
            catch {
            }

            return $null;

        }
        catch {
            $res2 = $_.Exception.InnerException.Response;
            $global:httpCode = $_.Exception.InnerException.HResult;
            $global:httperror = $_.exception.message;

            try {
                $global:location = $res2.Headers["Location"].ToString();
                return $global:location;
            }
            catch {
            }
        } 

        return $null;
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

    $response = az ad signed-in-user show | ConvertFrom-Json
    $date = get-date
    $demoType = "OpenAI"
    $body = '{"demoType":"#demoType#","userPrincipalName":"#userPrincipalName#","displayName":"#displayName#","companyName":"#companyName#","mail":"#mail#","date":"#date#"}'
    $body = $body.Replace("#userPrincipalName#", $response.userPrincipalName)
    $body = $body.Replace("#displayName#", $response.displayName)
    $body = $body.Replace("#companyName#", $response.companyName)
    $body = $body.Replace("#mail#", $response.mail)
    $body = $body.Replace("#date#", $date)
    $body = $body.Replace("#demoType#", $demoType)

    $uri = "https://registerddibuser.azurewebsites.net/api/registeruser?code=pTrmFDqp25iVSxrJ/ykJ5l0xeTOg5nxio9MjZedaXwiEH8oh3NeqMg=="
    $result = Invoke-RestMethod  -Uri $uri -Method POST -Body $body -Headers @{} -ContentType "application/json"

    $rgName = read-host "Enter the resource Group Name";
    $Region = (Get-AzResourceGroup -Name $rgName).Location
    $init =  (Get-AzResourceGroup -Name $rgName).Tags["DeploymentId"]
    $random =  (Get-AzResourceGroup -Name $rgName).Tags["UniqueId"] 
    $wsId =  (Get-AzResourceGroup -Name $rgName).Tags["WsId"] 
    $suffix = "$random-$init"
    $concatString = "$init$random"
    $cpuShell = "openai-compute-$init"
    $forms_open_ai_name = "form-openai-$suffix"    
    $dataLakeAccountName = "stopenai$concatString"
    if($dataLakeAccountName.length -gt 24)
    {
    $dataLakeAccountName = $dataLakeAccountName.substring(0,24)
    }
    $amlworkspacename = "aml-openAI-$suffix"
    $func_campaign_generation = "func-campaign-generator-$suffix"
    $asp_campaign_generation = "asp-campaign-generator-$suffix"
    $func_search_horizontal = "func-openai-search-horizontal-$suffix"
    $asp_search_horizontal = "asp-search-horizontal-$suffix"
    $func_recommend_images = "func-recommend-images-$suffix"
    $asp_recommend_images = "asp-recommend-images-$suffix"
    $func_regenerate_dalle = "func-regenerate-dalle-$suffix"
    $asp_regenerate_dalle = "asp-regenerate-dalle-$suffix"
    $func_pdf_indexer = "func-pdf-indexer-$suffix"
    $asp_pdf_indexer = "asp-pdf-indexer-$suffix"
    $app_openai_name = "app-open-ai-$suffix"
    $searchName = "srch-openai-$suffix"
    $cognitive_service_name = "cog-openai-$suffix"
    $subscriptionId = (Get-AzContext).Subscription.Id
    $tenantId = (Get-AzContext).Tenant.Id
    $usercred = ((az ad signed-in-user show) | ConvertFrom-JSON).UserPrincipalName
    $openAIResource = "openAIservice$concatString"
    if($openAIResource.length -gt 24)
    {
    $openAIResource = $openAIResource.substring(0,24)
    }

    $storage_account_key = (Get-AzStorageAccountKey -ResourceGroupName $rgName -AccountName $dataLakeAccountName)[0].Value

    $forms_open_ai_keys = Get-AzCognitiveServicesAccountKey -ResourceGroupName $rgName -name $forms_open_ai_name

    $forms_openai_key = $forms_open_ai_keys.Key1

    #retrieving openai endpoint
    $openAIEndpoint = az cognitiveservices account show -n $openAIResource -g $rgName | jq -r .properties.endpoint

    #retirieving primary key
    $openAIPrimaryKey = az cognitiveservices account keys list -n $openAIResource -g $rgName | jq -r .key1
    
    # Get search primary admin key
    Install-Module -Name Az.Search
    $adminKeyPair = Get-AzSearchAdminKeyPair -ResourceGroupName $rgName -ServiceName $searchName
    $searchServicePrimaryAdminKey = $adminKeyPair.Primary
    
    #retrieving cognitive service endpoint
    $cognitiveEndpoint = az cognitiveservices account show -n $cognitive_service_name -g $rgName | jq -r .properties.endpoint

    #retirieving cognitive service key
    $cognitivePrimaryKey = az cognitiveservices account keys list -n $cognitive_service_name -g $rgName | jq -r .key1
    
    #delpoying a model
    $openAIModel1 = az cognitiveservices account deployment create -g $rgName -n $openAIResource --deployment-name "gpt-35-turbo" --model-name "gpt-35-turbo" --model-version "0301" --model-format OpenAI
    
    $openAIModel2 = az cognitiveservices account deployment create -g $rgName -n $openAIResource --deployment-name "text-davinci-003" --model-name "text-davinci-003" --model-version "1" --model-format OpenAI

    #download azcopy command
    if ([System.Environment]::OSVersion.Platform -eq "Unix") {
        $azCopyLink = Check-HttpRedirect "https://aka.ms/downloadazcopy-v10-linux"

        if (!$azCopyLink) {
            $azCopyLink = "https://azcopyvnext.azureedge.net/release20200709/azcopy_linux_amd64_10.5.0.tar.gz"
        }

        Invoke-WebRequest $azCopyLink -OutFile "azCopy.tar.gz"
        tar -xf "azCopy.tar.gz"
        $azCopyCommand = (Get-ChildItem -Path ".\" -Recurse azcopy).Directory.FullName

        if ($azCopyCommand.count -gt 1) {
            $azCopyCommand = $azCopyCommand[0];
        }

        cd $azCopyCommand
        chmod +x azcopy
        cd ..
        $azCopyCommand += "\azcopy"
    } else {
        $azCopyLink = Check-HttpRedirect "https://aka.ms/downloadazcopy-v10-windows"

        if (!$azCopyLink) {
            $azCopyLink = "https://azcopyvnext.azureedge.net/release20200501/azcopy_windows_amd64_10.4.3.zip"
        }

        Invoke-WebRequest $azCopyLink -OutFile "azCopy.zip"
        Expand-Archive "azCopy.zip" -DestinationPath ".\" -Force
        $azCopyCommand = (Get-ChildItem -Path ".\" -Recurse azcopy.exe).Directory.FullName

        if ($azCopyCommand.count -gt 1) {
            $azCopyCommand = $azCopyCommand[0];
        }

        $azCopyCommand += "\azcopy"
    }

    #Uploading to storage containers
    Add-Content log.txt "-----------Uploading to storage containers-----------------"
    Write-Host "----Uploading to Storage Containers-----"

    $dataLakeContext = New-AzStorageContext -StorageAccountName $dataLakeAccountName -StorageAccountKey $storage_account_key

    RefreshTokens

    $destinationSasKey = New-AzStorageContainerSASToken -Container "data2" -Context $dataLakeContext -Permission rwdl
    $destinationUri = "https://$($dataLakeAccountName).blob.core.windows.net/data2$($destinationSasKey)"
    & $azCopyCommand copy "https://openaiddib.blob.core.windows.net/data2" $destinationUri --recursive

    $destinationSasKey = New-AzStorageContainerSASToken -Container "vouquahyaeyiepo" -Context $dataLakeContext -Permission rwdl
    $destinationUri = "https://$($dataLakeAccountName).blob.core.windows.net/vouquahyaeyiepo$($destinationSasKey)"
    & $azCopyCommand copy "https://openaiddib.blob.core.windows.net/vouquahyaeyiepo" $destinationUri --recursive

    $destinationSasKey = New-AzStorageContainerSASToken -Container "openai" -Context $dataLakeContext -Permission rwdl
    $destinationUri = "https://$($dataLakeAccountName).blob.core.windows.net/openai$($destinationSasKey)"
    & $azCopyCommand copy "https://openaiddib.blob.core.windows.net/openai" $destinationUri --recursive

    $destinationSasKey = New-AzStorageContainerSASToken -Container "contoso-cg-shopping" -Context $dataLakeContext -Permission rwdl
    $destinationUri = "https://$($dataLakeAccountName).blob.core.windows.net/contoso-cg-shopping$($destinationSasKey)"
    & $azCopyCommand copy "https://openaiddib.blob.core.windows.net/contoso-cg-shopping" $destinationUri --recursive

    $destinationSasKey = New-AzStorageContainerSASToken -Container "data3" -Context $dataLakeContext -Permission rwdl
    $destinationUri = "https://$($dataLakeAccountName).blob.core.windows.net/data3$($destinationSasKey)"
    & $azCopyCommand copy "https://openaiddib.blob.core.windows.net/data3" $destinationUri --recursive

    $destinationSasKey = New-AzStorageContainerSASToken -Container "contoso-cg-fallback2" -Context $dataLakeContext -Permission rwdl
    $destinationUri = "https://$($dataLakeAccountName).blob.core.windows.net/contoso-cg-fallback2$($destinationSasKey)"
    & $azCopyCommand copy "https://openaiddib.blob.core.windows.net/contoso-cg-fallback2" $destinationUri --recursive

    $destinationSasKey = New-AzStorageContainerSASToken -Container "pdfs" -Context $dataLakeContext -Permission rwdl
    $destinationUri = "https://$($dataLakeAccountName).blob.core.windows.net/pdfs$($destinationSasKey)"
    & $azCopyCommand copy "https://openaiddib.blob.core.windows.net/pdfs" $destinationUri --recursive

    ## powerbi
    Add-Content log.txt "------powerbi reports upload------"
    Write-Host "------------Powerbi Reports Upload------------"
    #Connect-PowerBIServiceAccount
    RefreshTokens
    $reportList = New-Object System.Collections.ArrayList
    $reports = Get-ChildItem "./artifacts/reports" | Select BaseName 
    foreach ($name in $reports) {
        $FilePath = "./artifacts/reports/$($name.BaseName)" + ".pbix"
        #New-PowerBIReport -Path $FilePath -Name $name -WorkspaceId $wsId
        
        write-host "Uploading PowerBI Report : $($name.BaseName)";
        $url = "https://api.powerbi.com/v1.0/myorg/groups/$wsId/imports?datasetDisplayName=$($name.BaseName)&nameConflict=CreateOrOverwrite";
        $fullyQualifiedPath = Resolve-Path -path $FilePath
        $fileBytes = [System.IO.File]::ReadAllBytes($fullyQualifiedPath);
        $fileEnc = [system.text.encoding]::GetEncoding("ISO-8859-1").GetString($fileBytes);
        $boundary = [System.Guid]::NewGuid().ToString();
        $LF = "`r`n";
        $bodyLines = (
            "--$boundary",
            "Content-Disposition: form-data",
            "",
            $fileEnc,
            "--$boundary--$LF"
        ) -join $LF

        $result = Invoke-RestMethod -Uri $url -Method POST -Body $bodyLines -ContentType "multipart/form-data; boundary=`"--$boundary`"" -Headers @{ Authorization = "Bearer $powerbitoken" }
        Start-Sleep -s 5 
		
        Add-Content log.txt $result
        $reportId = $result.id;

        $temp = "" | select-object @{Name = "FileName"; Expression = { "$($name.BaseName)" } }, 
        @{Name = "Name"; Expression = { "$($name.BaseName)" } }, 
        @{Name = "PowerBIDataSetId"; Expression = { "" } },
        @{Name = "ReportId"; Expression = { "" } },
        @{Name = "SourceServer"; Expression = { "" } }, 
        @{Name = "SourceDatabase"; Expression = { "" } }
		                        
        # get dataset                         
        $url = "https://api.powerbi.com/v1.0/myorg/groups/$wsId/datasets";
        $dataSets = Invoke-RestMethod -Uri $url -Method GET -Headers @{ Authorization = "Bearer $powerbitoken" };
		
        Add-Content log.txt $dataSets
        
        $temp.ReportId = $reportId;

        foreach ($res in $dataSets.value) {
            if ($res.name -eq $name.BaseName) {
                $temp.PowerBIDataSetId = $res.id;
            }
        }
                
        $list = $reportList.Add($temp)
    }
    Start-Sleep -s 20

    Write-Host  "-----------------AML Workspace ---------------"
    Add-Content log.txt "-----------AML Workspace -------------"
    RefreshTokens

    # $forms_openai_endpoint = "https://"+$forms_open_ai_name+".cognitiveservices.azure.com/"
    
    $filepath="./artifacts/amlnotebooks/config.json"
    $itemTemplate = Get-Content -Path $filepath
    $item = $itemTemplate.Replace("#OPENAI_API_ENDPOINT#", $openAIEndpoint).Replace("#OPENAI_API_KEY#", $openAIPrimaryKey)
    $filepath="./artifacts/amlnotebooks/config.json"
    Set-Content -Path $filepath -Value $item

    # #deleting a model from openai
    # az cognitiveservices account deployment delete -g $myResourceGroupName -n $myResourceName --deployment-name MyModel

    # #deleting openai resource
    # az cognitiveservices account delete --name MyopenAIResource -g OAIResourceGroup

    #create aml workspace
    az extension add -n azure-cli-ml
    az ml workspace create -n $amlworkspacename -g $rgName

    #attach a folder to set resource group and workspace name (to skip passing ws and rg in calls after this line)
    az ml folder attach -w $amlworkspacename -g $rgName -e aml
    start-sleep -s 10

    #create and delete a compute instance to get the code folder created in default store
    az ml computetarget create computeinstance -n $cpuShell -s "STANDARD_DS2_V2" -v

    #get default data store
    $defaultdatastore = az ml datastore show-default --resource-group $rgName --workspace-name $amlworkspacename --output json | ConvertFrom-Json
    $defaultdatastoreaccname = $defaultdatastore.account_name

    #get fileshare and code folder within that
    $storageAcct = Get-AzStorageAccount -ResourceGroupName $rgName -Name $defaultdatastoreaccname
    $share = Get-AzStorageShare -Prefix 'code' -Context $storageAcct.Context 
    $shareName = $share[0].Name
    $notebooks = Get-ChildItem "./artifacts/amlnotebooks" | Select BaseName
    foreach ($notebook in $notebooks) {

        if($notebook.BaseName -eq "config")
        {
            $source="./artifacts/amlnotebooks/"+$notebook.BaseName+".json"
            $path=$notebook.BaseName+".json"
        } 
        else {
            $source = "./artifacts/amlnotebooks/" + $notebook.BaseName + ".ipynb"
            $path = $notebook.BaseName + ".ipynb"
        }

        Write-Host " Uplaoding AML assets : $($notebook.BaseName)"
        Set-AzStorageFileContent `
            -Context $storageAcct.Context `
            -ShareName $shareName `
            -Source $source `
            -Path $path
    }

    #delete aks compute
    az ml computetarget delete -n $cpuShell -v

    #########################

    #Web App Section
    Add-Content log.txt "------unzipping poc web app------"
    Write-Host  "--------------Unzipping web app---------------"
    $zips = @("app-contoso-openai", "func-campaign-generation", "func-recommend-image", "func-regenerate-dalle", "func-pdf-indexer", "func-search-horizontal")
    foreach ($zip in $zips) {
        expand-archive -path "./artifacts/binaries/$($zip).zip" -destinationpath "./$($zip)" -force
    }

    #Web app
    Add-Content log.txt "------deploy poc web app------"
    Write-Host  "-----------------Deploy web app---------------"
    RefreshTokens

    $spname = "Open AI $random"

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

    Add-Content log.txt "-----python function apps zip deploy-------"
    Write-Host "----python function apps zip deploy------"

    $urlMainWebAppCors = "https://" + $app_openai_name + ".azurewebsites.net"

    Add-Content log.txt "----Updating CORS for function apps----"
    Write-Host "----Updating CORS for function apps----"

    $cors = az functionapp cors add -g $rgName -n $func_pdf_indexer --allowed-origins $urlMainWebAppCors
    $cors = az functionapp cors add -g $rgName -n $func_search_horizontal --allowed-origins $urlMainWebAppCors
    $cors = az functionapp cors add -g $rgName -n $func_campaign_generation --allowed-origins $urlMainWebAppCors
    $cors = az functionapp cors add -g $rgName -n $func_recommend_images --allowed-origins $urlMainWebAppCors
    $cors = az functionapp cors add -g $rgName -n $func_regenerate_dalle --allowed-origins $urlMainWebAppCors

    Add-Content log.txt "----CORS update successful----"
    Write-Host "----CORS update successful----"

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
    
    cd func-pdf-indexer
    try {
        func azure functionapp publish $func_pdf_indexer --force
        Write-Host "Code Publishing SUCCESSFUL for PDF INDEXER function app"
        # az webapp up --resource-group $rgName --name $func_pdf_indexer --plan $asp_pdf_indexer --location $Region --sku "B1"
    } catch {
        Write-Host "Code Publishing FAILED for PDF INDEXER function app"
        Write-Host "Please run PDF INDEXER subscript"
    }
    cd ..
    Start-Sleep -s 20
    az webapp restart  --name $func_pdf_indexer --resource-group $rgName
    
    ## Training the Knowledge Base      -------   index_name ="prod-responsibleai-search" container_name = "knowledge-base-responsibleai"
    $urlPdfIndexer = "https://" + $func_pdf_indexer  + ".azurewebsites.net/api/pdfindexer"
    $urlPdfs = "https://" + $dataLakeAccountName + ".blob.core.windows.net/pdfs/"  

    $containerName = "pdfs"

    $context = New-AzStorageContext -StorageAccountName $dataLakeAccountName -StorageAccountKey $storage_account_key

    # $containerName = Get-AzStorageContainer -Name $dataLakeAccountName -Context $context

    $blobs = Get-AzStorageBlob -Container $containerName -Context $context

    foreach ($file in $blobs.Name) {
        
        $newPdfUrl = $urlPdfs + $file

        $body = @{
            index_name ="prod-responsibleai-search"
            container_name = "knowledge-base-responsibleai"
            blob_url = $newPdfUrl
        }

        try {
            $response = Invoke-RestMethod -Uri $urlPdfIndexer -Method POST -body $body
            Write-Host "KnowledgeBase Training successful for $file"
        } catch {
            Write-Host "KnowledgeBase Training UNSUCCESSFUL for $file"
        }

    }

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
    
    cd func-search-horizontal
    try {
        func azure functionapp publish $func_search_horizontal --force
        Write-Host "Code Publishing SUCCESSFUL for SEARCH HORIZONTAL function app"
        # az webapp up --resource-group $rgName --name $func_search_horizontal --plan $asp_search_horizontal --location $Region --sku "B1"
    } catch {
        Write-Host "Code Publishing FAILED for SEARCH HORIZONTAL function app"
        Write-Host "Please run SEARCH HORIZONTAL subscript"
    }    
    cd ..
    Start-Sleep -s 20
    az webapp restart  --name $func_search_horizontal --resource-group $rgName
    
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

    cd func-campaign-generation
    try {
        func azure functionapp publish $func_campaign_generation --force
        Write-Host "Code Publishing SUCCESSFUL for CAMPAIGN GENERATION function app"
        # az webapp up --resource-group $rgName --name $func_campaign_generation --plan $asp_campaign_generation --location $Region --sku "B1"
    } catch {
        Write-Host "Code Publishing FAILED for CAMPAIGN GENERATION function app"
        Write-Host "Please run CAMPAIGN GENERATION subscript"
    }  
    cd ..
    Start-Sleep -s 20
    az webapp restart  --name $func_campaign_generation --resource-group $rgName

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
    
    cd func-recommend-image
    func azure functionapp publish $func_recommend_images
    # az webapp up --resource-group $rgName --name $func_recommend_images --plan $asp_recommend_images --location $Region --sku "B1"
    cd ..
    Start-Sleep -s 20
    az webapp restart  --name $func_recommend_images --resource-group $rgName
    
    ## function regenerate dalle
    $configFO = az functionapp config appsettings set --name $func_regenerate_dalle --resource-group $rgName --settings OPENAI_API_KEY=$openAIPrimaryKey
    $configFO = az functionapp config appsettings set --name $func_regenerate_dalle --resource-group $rgName --settings OPENAI_API_ENDPOINT=$openAIEndpoint
    
    cd func-regenerate-dalle
    func azure functionapp publish $func_regenerate_dalle
    # az webapp up --resource-group $rgName --name $func_regenerate_dalle --plan $asp_regenerate_dalle --location $Region --sku "B1"
    cd ..
    Start-Sleep -s 20
    az webapp restart  --name $func_regenerate_dalle --resource-group $rgName

    $endtime = get-date
    $executiontime = $endtime - $starttime
    Write-Host "Execution Time - "$executiontime.TotalMinutes

    Write-Host  "-----------------Execution Complete----------------"
}
