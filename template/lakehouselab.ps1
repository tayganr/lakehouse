Write-Host "`n[INFO] Getting a list of Azure subsciptions that the current account can access..."
$subscriptions = Get-AzSubscription

$counter = 0
Write-Host "`n------------------------------------------`n         YOUR AZURE SUBSCRIPTIONS         `n------------------------------------------"
ForEach ($x in $subscriptions) {
    if ($x.State -eq "Enabled") {
        $counter++
        Write-Host "[$($counter)] ($($x.Id)) $($x.Name)"
    }
}
$selectSub = Read-Host "`nPlease select an Azure subscrpition by specifying a number between 1 and $($counter)"
$targetSubscription = $subscriptions[$selectSub]

Write-Host "`n[INFO] Setting the Azure context to: $($targetSubscription.Name)"
$setContext = Set-AzContext -Subscription $targetSubscription.Id

$requiredResourceProviers = @("Microsoft.Authorization","Microsoft.EventGrid","Microsoft.Sql","Microsoft.Storage","Microsoft.Synapse","Microsoft.DataFactory")
Write-Host "[INFO] Getting all resource providers registered with the current subscription..."
$registeredResourceProviders = Get-AzResourceProvider

Write-Host "[INFO] Registering missing resource providers..."
$isMissing = $false
ForEach ($requiredResourceProvider in $requiredResourceProviers) {
    if ($requiredResourceProvider -in $registeredResourceProviders.ProviderNamespace) {
        continue
    } else {
        $isMissing = $true
        Register-AzResourceProvider -ProviderNamespace $requiredResourceProvider
    }
}

if ($isMissing) {
    Write-Host "[INFO] Missing resource providers are now registering. To check the registration status, navigate to Azure Portal > Subscriptions > YOUR_AZURE_SUBSCRIPTION > Resouce Providers."
} else {
    Write-Host "[INFO] All required resource providers are registered.`n"
}
