$url = "https://vretfcoresa.blob.core.windows.net/software/spss-appv.zip"
$file = "C:\installation-sources\spss-appv.zip"

(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
Expand-Archive $file C:\installation-sources\spss-appv

Enable-Appv
Add-AppvClientPackage c:\installation-sources\spss-appv\i02-spss-25-en-x64-v02.appv | Publish-AppvClientPackage -Global | Mount-AppvClientPackage | Out-Null

$spssLocation = "C:\ProgramData\Microsoft\AppV\Client\Integration\5CC1D5AD-CB2E-4EB6-9EA7-DAC92C9B6F27\Root\VFS\ProgramFilesX64\IBM\SPSS\Statistics\25\stats.exe"
Add-MpPreference -ControlledFolderAccessAllowedApplications $spssLocation
netsh advfirewall firewall add rule name="IBM SPSS Statistics 25.0" profile=public,domain dir=in action=allow protocol=TCP program=$spssLocation
netsh advfirewall firewall add rule name="IBM SPSS Statistics 25.0" profile=public,domain dir=in action=allow protocol=UDP program=$spssLocation
Import-Module "$env:ChocolateyInstall\helpers\chocolateyInstaller.psm1"; Install-ChocolateyShortcut -ShortcutFilePath "$home\Desktop\SPSS.lnk" -TargetPath $spssLocation