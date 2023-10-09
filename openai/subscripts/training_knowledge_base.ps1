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
$func_pdf_indexer = "func-pdf-indexer-$suffix"
$dataLakeAccountName = "stopenai$concatString"
if($dataLakeAccountName.length -gt 24)
{
$dataLakeAccountName = $dataLakeAccountName.substring(0,24)
}
$storage_account_key = (Get-AzStorageAccountKey -ResourceGroupName $rgName -AccountName $dataLakeAccountName)[0].Value


## Training the Knowledge Base      -------   index_name ="prod-responsibleai-search" container_name = "knowledge-base-responsibleai"
$urlPdfIndexer = "https://" + $func_pdf_indexer  + ".azurewebsites.net/api/pdfindexer"
$urlPdfs = "https://" + $dataLakeAccountName + ".blob.core.windows.net/pdfs/"  

$containerName = "pdfs"

$context = New-AzStorageContext -StorageAccountName $dataLakeAccountName -StorageAccountKey $storage_account_key

# $container = Get-AzStorageContainer -Name $containerName -Context $context

$blobs = Get-AzStorageBlob -Container $containerName -Context $context

foreach ($file in $blobs.Name) {
    
    $newPdfUrl = $urlPdfs + $file

    $body = @{
        index_name ="prod-responsibleai-search"
        container_name = "knowledge-base-responsibleai"
        blob_url = $newPdfUrl
    }

    $response = Invoke-RestMethod -Uri $urlPdfIndexer -Method POST -body $body
    Write-Host "KnowledgeBase Training successful for $file"
}
