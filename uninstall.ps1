$scriptDirectory = Split-Path $MyInvocation.MyCommand.Path -Parent
Import-Module "$scriptDirectory\GitStatusCachePoshClient.psm1"

Write-Host -ForegroundColor Green 'Removing GitStatusCache.exe.'
Remove-GitStatusCache
Remove-Module "GitStatusCachePoshClient"

if(Test-Path $PROFILE)
{
    Write-Host -ForegroundColor Green 'Removing git-status-cache-posh-client from $PROFILE.'
    $firstProfileLine = '# Import git-status-cache-posh-client'
    $secondProfileLine = [RegEx]::Escape("Import-Module '$scriptDirectory\GitStatusCachePoshClient.psm1'")
    Get-Content $profile | Where-Object { ($_ -notmatch $firstProfileLine) -and ($_ -notmatch $secondProfileLine) } | Set-Content "$profile.temp"
    Move-Item "$profile.temp" $profile -Force
}

Write-Host -ForegroundColor Green 'Removed git-status-cache-posh-client.'
Write-Host -ForegroundColor Green 'Please reload your profile for the changes to take effect:'
Write-Host -ForegroundColor Green '    . $PROFILE'