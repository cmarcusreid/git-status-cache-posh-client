$scriptDirectory = Split-Path $MyInvocation.MyCommand.Path -Parent
$installDirectory = Join-Path $scriptDirectory "bin"
New-Item -ItemType Directory -Force -Path $installDirectory > $null

Stop-Process -Name "GitStatusCache" -Force -ErrorAction SilentlyContinue
Start-Sleep -m 50

$exePath = Join-Path $installDirectory "GitStatusCache.exe"
if (Test-Path $exePath)
{
    Remove-Item "$exePath"
}

Write-Host "Downloading $exePath..."
wget -Uri "https://github.com/cmarcusreid/git-status-cache/releases/download/v0.1.4-alpha/GitStatusCache.exe" -OutFile "$exePath"

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

$profileLine = "Import-Module '$scriptDirectory\GitStatusCachePoshClient.psm1'"
if(Select-String -Path $PROFILE -Pattern $profileLine -Quiet -SimpleMatch)
{
    return
}

Write-Host "Adding git-status-cache-posh-client to profile..."
@"

# Import git-status-cache-posh-client
$profileLine

"@ | Out-File $PROFILE -Append -Encoding (Get-FileEncoding $PROFILE)

Write-Host 'git-status-cache-posh-client successfully installed!'
Write-Host 'Please reload your profile for the changes to take effect:'
Write-Host '    . $PROFILE'