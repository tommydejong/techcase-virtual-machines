# Set Network Location to Private
Set-NetConnectionProfile -Name "Network" -NetworkCategory Private

# Disable UAC
New-ItemProperty -Path "HKLM:Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name EnableLUA -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name ConsentPromptBehaviorAdmin -PropertyType DWord -Value 0 -Force

# Set Controller Folder Access (against ransomware) to Enabled
Set-MpPreference -EnableControlledFolderAccess Enabled

# Do not allow null sessions
# ID 90044 / CVE-2002-1117 / CVE-2000-1200
New-ItemProperty -Path "HKLM:System\CurrentControlSet\Control\Lsa" -Name RestrictAnonymous -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:System\CurrentControlSet\Services\LanmanServer\Parameters" -Name RestrictNullSessAccess -PropertyType DWord -Value 1 -Force

# Disable AutoPlay for Windows Explorer
# ID 105170
New-ItemProperty -Path "HKLM:Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoDriveTypeAutoRun -PropertyType DWord -Value 255 -Force

# Disable Cached Logon Credential
# ID 90007
New-ItemProperty -Path "HKLM:Software\Microsoft\Windows Nt\CurrentVersion\Winlogon" -Name CachedLogonsCount -PropertyType DWord -Value 0 -Force

# Disable Guest account
# ID 105228
Get-LocalUser Guest | Disable-LocalUser

# Enable TLS 1.2 to follow the "Windows web servers should be configured to use secure communication protocols" security recommendation
New-ItemProperty -Path "HKLM:Software\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp" -Name DefaultSecureProtocols -PropertyType DWord -Value 0xAA0 -Force

# Disable Print Spooler Service
# Windows Print Spooler Remote Code Execution Vulnerability - CVE-2021-34527
Stop-Service -Name Spooler -Force; Set-Service -Name Spooler -StartupType Disabled
