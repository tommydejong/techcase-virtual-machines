Param
(
    [String] $subscriptionID,
    [String] $workspaceSA,
    [String] $workspaceRG
)

# Check if parameter is set, otherwise use value from env variable set by Ansible
$subscriptionID = if($PSBoundParameters.ContainsKey('subscriptionID')) { $subscriptionID } else { $ENV:VREsubscriptionID }
$workspaceSA = if($PSBoundParameters.ContainsKey('workspaceSA')) { $workspaceSA } else { $ENV:VREworkspaceSA }
$workspaceRG = if($PSBoundParameters.ContainsKey('workspaceRG')) { $workspaceRG } else { $ENV:VREworkspaceRG }

$AZFLOGFILE = "$env:TEMP\mount-azure-file-share.ps1.log"
New-Item -Path $AZFLOGFILE -Force

Function Write-Log([String] $logText) {
    '{0:u}: {1}' -f (Get-Date), $logText | Out-File $AZFLOGFILE -Append
    
}

$FileShareURI = "\\$workspaceSA.file.core.windows.net\vredata"

# Get the storage account access key
Function Get-Storage-Account-Access-Key([String] $subscriptionID, [String] $workspaceSA, [String] $workspaceRG) {
    Write-Log "Fetching access key for storage account $workspaceSA"
    $MSI_ENDPOINT = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/"
    try {
        # Get access token
        $response = Invoke-WebRequest -Uri $MSI_ENDPOINT -UseBasicParsing -Method GET -Headers @{Metadata = "true" }
        $content = $response.Content | ConvertFrom-Json
        $accessToken = $content.access_token
        Write-Log "Access token acquired using Azure managed identity"
        # Get storage account access key
        $storageAccountNameURL = "https://management.azure.com/subscriptions/" + $subscriptionID + "/resourceGroups/" + $workspaceRG + "/providers/Microsoft.Storage/storageAccounts/" + $workspaceSA + "/listKeys?api-version=2021-04-01&`$expand=kerb"
        $getKeys= Invoke-WebRequest -Uri $storageAccountNameURL -UseBasicParsing -Method POST -Headers @{Authorization = "Bearer $accessToken" }
        $allKeys = $getKeys | ConvertFrom-Json
        Write-Log "Storage account access keys obtained"
        $workspaceSAkey1 = $allKeys.keys[0].value
        Write-Log "Grabbed storage account key1"
    }
    catch {
        throw $_
    }
    return $workspaceSAkey1
}

# Connect to Azure File Share
$accessKey = Get-Storage-Account-Access-Key $subscriptionID $workspaceSA $workspaceRG
Write-Log "Creating Powershell Credential object containing storage account credentials"
$secureKey = ConvertTo-SecureString -String $accessKey -AsPlainText -Force
$PSCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "Azure\$workspaceSA", $secureKey
    
# See if a PSDrive mapping was already made    
$Mapping = Test-Path Z:
# If there a mapping then remove it
if($Mapping)
{
    Remove-PSDrive Z
    Write-Log "Drive mounting removed, moving on to re-mount..."
}
# Create a PSDrive mapping 
Write-Log "Mounting Azure File Share: vredata on $workspaceSA..."
New-PSDrive -Name "Z" -Root $FileShareURI -Persist -PSProvider "FileSystem" -Scope "Global" -Credential $PSCredential

# Check if mapping was successful
$Mapping = Test-Path Z:
if($Mapping)
{
    Write-Log "Successfully mounted on drive letter Z:!"
    # Create shortcut using Chocolatey helpers
    Import-Module $env:ChocolateyInstall\helpers\chocolateyInstaller.psm1; Install-ChocolateyShortcut -ShortcutFilePath "$home\Desktop\Azure File Share.lnk" -TargetPath Z:\
}
else 
{
    Write-Log "Drive mounting failed!"
}