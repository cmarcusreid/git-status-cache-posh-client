if (Get-Module GetStatusCachePoshClient) { return }

Push-Location $psScriptRoot
. .\GitStatusCachePoshClient.ps1
Pop-Location

Export-ModuleMember -Function @('Get-GitStatusFromCache')