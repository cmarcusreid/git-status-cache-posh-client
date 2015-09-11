$ErrorActionPreference = 'Stop'

$packageName = 'git-status-cache-posh-client'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url = 'https://github.com/cmarcusreid/git-status-cache-posh-client/archive/v1.0.0.zip'

Install-ChocolateyZipPackage $packageName $url $toolsDir

$subfolder = get-childitem $toolsDir -recurse -include 'git-status-cache-posh-client-1.0.0' | select -First 1
$installer = Join-Path $subfolder 'install.ps1'
& $installer