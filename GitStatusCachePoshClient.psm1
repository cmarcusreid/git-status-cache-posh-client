if (Get-Module GitStatusCachePoshClient) { return }

if (-not (Get-Module Microsoft.Powershell.Utility))
{
	Import-Module Microsoft.Powershell.Utility
}

Push-Location $psScriptRoot
. .\GitStatusCachePoshClient.ps1
Pop-Location

Export-ModuleMember -Function @('Get-GitStatusFromCache')
Export-ModuleMember -Function @('Get-GitStatusCacheStatistics')
Export-ModuleMember -Function @('Restart-GitStatusCache')
Export-ModuleMember -Function @('Update-GitStatusCache')