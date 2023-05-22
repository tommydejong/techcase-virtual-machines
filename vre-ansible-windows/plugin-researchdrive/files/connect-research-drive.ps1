Param
(
    [String] $workspaceKV,
    [String] $instance
)

# Check if parameter is set, otherwise use value from env variable set by Ansible
$workspaceKV = if($PSBoundParameters.ContainsKey('workspaceKV')) { $workspaceKV } else { $ENV:VREResearchDriveKV }
$instance = if($PSBoundParameters.ContainsKey('instance')) { $instance } else { $ENV:VREinstance }

# Fixed values from Terraform module
$secretKey = "rdrive-key"
$secretUserName = "rdrive-username"

# Generate research drive URL based on instance variable
$rdriveURI = "https://" + $instance.ToLower() + ".data.surfsara.nl/remote.php/nonshib-webdav/"

$RDLOGFILE = "$env:TEMP\connect-research-drive.ps1.log"
New-Item -Path $RDLOGFILE -Force

Function Write-Log([String] $logText) {
    '{0:u}: {1}' -f (Get-Date), $logText | Out-File $RDLOGFILE -Append
}

Write-Log "Key vault to be used: $workspaceKV in instance $instance"
Write-Log "ResearchDrive URI to be used: $rdriveURI"

# Get ResearchDrive credentials from key vault
Function Get-ResearchDrive-Credentials([String] $workspaceKV, [String] $secretUserName, [String] $secretKey) {
    Write-Log "Fetching ResearchDrive username $secretUserName and password $secretKey from key vault $workspaceKV."
    $MSI_ENDPOINT = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net"
    try {
        # Get access token
        $response = Invoke-WebRequest -Uri $MSI_ENDPOINT -UseBasicParsing -Method GET -Headers @{Metadata = "true" }
        $content = $response.Content | ConvertFrom-Json
        $accessToken = $content.access_token
        Write-Log "Access token acquired using Azure managed identity"
        # Get ResearchDrive username from key vault
        $azureKeyVaultNameURL = "https://" + $workspaceKV + ".vault.azure.net/secrets/" + $secretUserName + "?api-version=2016-10-01"
        $kvSecret = Invoke-WebRequest -Uri $azureKeyVaultNameURL -UseBasicParsing -Method GET -Headers @{Authorization = "Bearer $accessToken" }
        $kvContent = $kvSecret | ConvertFrom-Json
        $user = $kvContent.value
        Write-Log "$secretUsername $user extracted from key vault $workspaceKV"
        # Get ResearchDrive password from key vault
        $azureKeyVaultNameURL = "https://" + $workspaceKV + ".vault.azure.net/secrets/" + $secretKey + "?api-version=2016-10-01"
        $kvSecret = Invoke-WebRequest -Uri $azureKeyVaultNameURL -UseBasicParsing -Method GET -Headers @{Authorization = "Bearer $accessToken" }
        $kvContent = $kvSecret | ConvertFrom-Json
        $key = $kvContent.value
        Write-Log "$secretKey extracted from key vault $workspaceKV"
    }
    catch {
        throw $_
    }
    Write-Log "Found the username $secretUsername and password $secretKey in key vault $workspaceKV."
    # Create a custom object containing the credentials
    $credentials = "" | Select-Object -Property user,key
    $credentials.user = $user
    $credentials.key = $key
    return $credentials
}

Function Main { 
    $credentials = Get-ResearchDrive-Credentials $workspaceKV $secretUserName $secretKey

    # See if a mapping was already made    
    $Mapping = Test-Path R:
    # If there a mapping then remove it
    if($Mapping)
        {
            net use r: /delete
            Write-Log "Drive mounting removed, moving on to re-mount..."
        }

    Write-Log "Mounting $rdriveURI using username $($credentials.user)..."
    net use r: $rdriveURI /user:$($credentials.user) $($credentials.key)
}

try {
    Main
    # Check if mapping was successful
    $Mapping = Test-Path R:
    if($Mapping)
        {
            Write-Log "ResearchDrive successfully mounted as drive letter R!"
            # Create shortcut using Chocolatey helpers
            Import-Module $env:ChocolateyInstall\helpers\chocolateyInstaller.psm1; Install-ChocolateyShortcut -ShortcutFilePath "$home\Desktop\Research Drive.lnk" -TargetPath R:\
        }
    else 
        {
            Write-Log "Drive mounting failed!"
        }
}
catch {
    Write-Log "$_"
    Throw $_   
}
