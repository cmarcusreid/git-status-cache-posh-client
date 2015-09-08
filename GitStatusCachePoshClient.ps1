function Get-BinPath
{
    $scriptDirectory = Split-Path $PSCommandPath -Parent
    return Join-Path $scriptDirectory "bin"
}

function Get-ExecutablePath
{
    $binPath = Get-BinPath
    return Join-Path $binPath "GitStatusCache.exe"
}

function Remove-GitStatusCache
{
    $process = Get-Process -Name "GitStatusCache" -ErrorAction SilentlyContinue
    if ($process -ne $null)
    {
        Stop-Process -Name "GitStatusCache" -Force -ErrorAction SilentlyContinue
        Start-Sleep -m 50
    }

    $binPath = Get-BinPath
    if (Test-Path $binPath)
    {
        Remove-Item -Path $binPath -Force -Recurse -ErrorAction Stop
    }
}

function Test-Release($release)
{
    # This script understands the named pipe protocol used by V1 git-status-cache releases.
    if (-not $release.tag_name.StartsWith("v1."))
    {
        return $false
    }

    foreach ($asset in $release.assets)
    {
        if ($asset.browser_download_url.EndsWith("GitStatusCache.exe"))
        {
            return $true;
        }
    }

    return $false
}

function Get-ExecutableDownloadUrl
{
    $release = wget -Uri "https://api.github.com/repos/cmarcusreid/git-status-cache/releases/latest" | ConvertFrom-Json
    if (-not (Test-Release $release))
    {
        Write-Host -ForegroundColor Yellow "Latest git-status-cache release is not compatible with this version of git-status-cache-posh-client."
        Write-Host -ForegroundColor Yellow "Please update git-status-cache-posh-client."
        Write-Host -ForegroundColor Yellow "Falling back to latest compatible release of git-status-cache."
        $allReleases = wget -Uri "https://api.github.com/repos/cmarcusreid/git-status-cache/releases" | ConvertFrom-Json | Sort-Object -Descending -Property "published_at"
        foreach ($candidateRelease in $allReleases)
        {
            if (Test-Release $candidateRelease)
            {
                $release = $candidateRelease
                break
            }
        }
    }

    foreach ($asset in $release.assets)
    {
        if ($asset.browser_download_url.EndsWith("GitStatusCache.exe"))
        {
            return $asset.browser_download_url;
        }
    }

    Write-Error "Failed to find GitStatusCache.exe download URL."
}

function Update-GitStatusCache
{
    Remove-GitStatusCache
    $binPath = Get-BinPath
    if(-not (Test-Path $binPath))
    {
        Write-Host -ForegroundColor Green "Creating directory for GitStatusCache.exe at $binPath."
        New-Item -ItemType Directory -Force -Path $binPath -ErrorAction Stop | Out-Null
    }

    $executablePath = Join-Path $binPath "GitStatusCache.exe"
    if (Test-Path $executablePath)
    {
        Remove-Item "$executablePath"
    }

    Write-Host -ForegroundColor Green "Downloading $executablePath."
    $executableUrl = Get-ExecutableDownloadUrl
    wget -Uri $executableUrl -OutFile "$executablePath"
}

function Start-GitStatusCache
{
    $process = Get-Process -Name "GitStatusCache" -ErrorAction SilentlyContinue
    if ($process -eq $null)
    {
        $executablePath = Get-ExecutablePath
        if (-not (Test-Path $executablePath))
        {
            Throw [System.InvalidOperationException] "GitStatusCache.exe was not found. Call Update-GitStatusCache to download."
            return $false
        }
        Start-Process -FilePath $executablePath
    }
}

function Disconnect-Pipe
{
    $Global:GitStatusCacheClientPipe.Dispose()
    $Global:GitStatusCacheClientPipe = $null
}

function Connect-Pipe
{
    if ($Global:GitStatusCacheClientPipe -ne $null -and -not $Global:GitStatusCacheClientPipe.IsConnected)
    {
        Disconnect-Pipe
    }

    if ($Global:GitStatusCacheClientPipe -eq $null)
    {
        Start-GitStatusCache
        $Global:GitStatusCacheClientPipe = new-object System.IO.Pipes.NamedPipeClientStream '.','GitStatusCache','InOut','WriteThrough'
        $Global:GitStatusCacheClientPipe.Connect(100)
        $Global:GitStatusCacheClientPipe.ReadMode = 'Message'
    }
}

function Send-RequestToGitStatusCache($requestJson)
{
    Connect-Pipe

    $remainingRetries = 1
    while ($remainingRetries -ge 0)
    {
        $encoding = [System.Text.Encoding]::UTF8
        $requestBuffer = $encoding.GetBytes($requestJson)

        $wasPipeBroken = $false
        try
        {
            $Global:GitStatusCacheClientPipe.Write($requestBuffer, 0, $requestBuffer.Length)
        }
        catch [system.io.ioexception]
        {
            Disconnect-Pipe
            Connect-Pipe
            --$remainingRetries
            $wasPipeBroken = $true
        }

        if (-not $wasPipeBroken)
        {
            $chunkSize = $Global:GitStatusCacheClientPipe.InBufferSize
            $totalBytesRead = 0
            $responseBuffer = $null
            do
            {
                $chunk = new-object byte[] $chunkSize
                $bytesRead = $Global:GitStatusCacheClientPipe.Read($chunk, 0, $chunkSize)
                $totalBytesRead += $bytesRead

                if ($responseBuffer -eq $null)
                {
                    $responseBuffer = $chunk
                }
                else
                {
                    $responseBuffer += $chunk
                }
            } while ($bytesRead -eq $chunkSize)

            $response = $encoding.GetString($responseBuffer, 0, $totalBytesRead)
            $responseObject = ConvertFrom-Json $response
            return $responseObject
        }
    }
}

function Stop-GitStatusCache
{
    $request = new-object psobject -property @{ Version = 1; Action = "Shutdown" } | ConvertTo-Json -Compress
    return Send-RequestToGitStatusCache($request)
}

function Restart-GitStatusCache
{
    Stop-GitStatusCache
    Connect-Pipe
}

function Get-GitStatusFromCache
{
    $request = new-object psobject -property @{ Version = 1; Action = "GetStatus"; Path = (Get-Location).Path } | ConvertTo-Json -Compress
    return Send-RequestToGitStatusCache($request)
}

function Get-GitStatusCacheStatistics
{
    $request = new-object psobject -property @{ Version = 1; Action = "GetCacheStatistics"; } | ConvertTo-Json -Compress
    return Send-RequestToGitStatusCache($request)
}