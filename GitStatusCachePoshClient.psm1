if (Get-Module GitStatusCachePoshClient) { return }

Push-Location $psScriptRoot
. .\GitStatusCachePoshClient.ps1
Pop-Location

Export-ModuleMember -Function @('Get-GitStatusFromCache')
Export-ModuleMember -Function @('Get-GitStatusCacheStatistics')
Export-ModuleMember -Function @('Restart-GitStatusCache')
Export-ModuleMember -Function @('Update-GitStatusCache')