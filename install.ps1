$scriptDirectory = Split-Path $MyInvocation.MyCommand.Path -Parent
$installDirectory = Join-Path $scriptDirectory "bin"
if(-not (Test-Path $installDirectory))
{
    Write-Host "Creating directory for GitStatusCache.exe.`n$installDirectory"
    New-Item -ItemType Directory -Force -Path $installDirectory -ErrorAction Stop
}

Stop-Process -Name "GitStatusCache" -Force -ErrorAction SilentlyContinue
Start-Sleep -m 50

$exePath = Join-Path $installDirectory "GitStatusCache.exe"
if (Test-Path $exePath)
{
    Remove-Item "$exePath"
}

Write-Host "Downloading $exePath."
wget -Uri "https://github.com/cmarcusreid/git-status-cache/releases/download/v1.0.0/GitStatusCache.exe" -OutFile "$exePath"

if(-not (Test-Path $PROFILE))
{
    Write-Host "Creating PowerShell profile.`n$PROFILE"
    New-Item $PROFILE -Force -Type File -ErrorAction Stop
}

$profileLine = "Import-Module '$scriptDirectory\GitStatusCachePoshClient.psm1'"
if(Select-String -Path $PROFILE -Pattern $profileLine -Quiet -SimpleMatch)
{
    Write-Host 'Found existing git-status-cache-posh-client import in $PROFILE.'
    Write-Host 'git-status-cache-posh-client successfully installed!'
    return
}

# Adapted from http://www.west-wind.com/Weblog/posts/197245.aspx
function Get-FileEncoding($Path)
{
    $bytes = [byte[]](Get-Content $Path -Encoding byte -ReadCount 4 -TotalCount 4)

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

Write-Host "Adding git-status-cache-posh-client to profile."
@"

# Import git-status-cache-posh-client
$profileLine

"@ | Out-File $PROFILE -Append -Encoding (Get-FileEncoding $PROFILE)

Write-Host 'git-status-cache-posh-client successfully installed!'
Write-Host 'Please reload your profile for the changes to take effect:'
Write-Host '    . $PROFILE'