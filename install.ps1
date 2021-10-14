$scriptDirectory = Split-Path $MyInvocation.MyCommand.Path -Parent
Import-Module "$scriptDirectory\GitStatusCachePoshClient.psm1"
Update-GitStatusCache

if(-not (Test-Path $PROFILE))
{
    Write-Host -ForegroundColor Green "Creating PowerShell profile.`n$PROFILE"
    New-Item $PROFILE -Force -Type File -ErrorAction Stop
}

$profileLine = "Import-Module '$scriptDirectory\GitStatusCachePoshClient.psm1'"
if(Select-String -Path $PROFILE -Pattern $profileLine -Quiet -SimpleMatch)
{
    Write-Host -ForegroundColor Green 'Found existing git-status-cache-posh-client import in $PROFILE.'
    Write-Host -ForegroundColor Green 'git-status-cache-posh-client successfully installed!'
    return
}

# Adapted from http://www.west-wind.com/Weblog/posts/197245.aspx
function Get-FileEncoding($Path)
{
    if ($PSVersionTable.PSCompatibleVersions -contains "3.0") {
        $bytes = [byte[]](Get-Content $Path -Raw -ReadCount 4 -TotalCount 4)
    } else {
        $bytes = [byte[]](Get-Content $Path -Encoding byte -ReadCount 4 -TotalCount 4)
    }

    if(!$bytes) { return 'utf8' }

    switch -regex ('{0:x2}{1:x2}{2:x2}{3:x2}' -f $bytes[0],$bytes[1],$bytes[2],$bytes[3]) {
        '^efbbbf'   { return 'utf8' }
        '^2b2f76'   { return 'utf7' }
        '^fffe'     { return 'unicode' }
        '^feff'     { return 'bigendianunicode' }
        '^0000feff' { return 'utf32' }
        default     { return 'ascii' }
    }
}

Write-Host -ForegroundColor Green "Adding git-status-cache-posh-client to profile."
@"

# Import git-status-cache-posh-client
$profileLine
"@ | Out-File $PROFILE -Append -Encoding (Get-FileEncoding $PROFILE)

Write-Host -ForegroundColor Green 'git-status-cache-posh-client successfully installed!'
Write-Host -ForegroundColor Green 'Please reload your profile for the changes to take effect:'
Write-Host -ForegroundColor Green '    . $PROFILE'