$ErrorActionPreference = 'Stop'

$packageName = 'git-status-cache-posh-client'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$subfolder = get-childitem $toolsDir -recurse -include 'git-status-cache-posh-client-1.0.0' | select -First 1
$uninstaller = Join-Path $subfolder 'uninstall.ps1'
& $uninstaller

Uninstall-ChocolateyZipPackage -PackageName $packageName -ZipFileName $packageName

