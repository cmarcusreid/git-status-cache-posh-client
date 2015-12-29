# git-status-cache-posh-client #

PowerShell client for retrieving git repository information from [git-status-cache](https://github.com/cmarcusreid/git-status-cache). Communicates with the cache process via named pipe. 

## Setup ##

Run install.ps1 to download GitStatusCache.exe and add the module registration to your $PROFILE. This will make the `Get-GitStatusFromCache` command available.

	D:\git-status-cache-posh-client [master +1 ~0 -0 !]> Get-Module GitStatusCachePoshClient

	ModuleType Version    Name                                ExportedCommands
	---------- -------    ----                                ----------------
	Script     0.0        GitStatusCachePoshClient            {Get-GitStatusCacheStatistics, Get-GitStatusFromCache, Restart-GitStatusCache}

### Chocolatey package ###

Alternatively git-status-cache-posh-client can be installed via chocolatey.

	choco install git-status-cache-posh-client

##Usage##

Sample output:
	
	D:\git-status-cache-posh-client [master +0 ~1 -0]> Get-GitStatusFromCache
	
	Version           : 1
	Path              : D:\git-status-cache-posh-client
	RepoPath          : D:/git-status-cache-posh-client/.git/
	WorkingDir        : D:/git-status-cache-posh-client/
	State             :
	Branch            : master
	Upstream          : origin/master
	AheadBy           : 0
	BehindBy          : 0
	IndexAdded        : {}
	IndexModified     : {README.md}
	IndexDeleted      : {}
	IndexTypeChange   : {}
	IndexRenamed      : {}
	WorkingAdded      : {}
	WorkingModified   : {}
	WorkingDeleted    : {}
	WorkingTypeChange : {}
	WorkingRenamed    : {}
	WorkingUnreadable : {}
	Ignored           : {}
	Conflicted        : {}
	
	
	D:\git-status-cache-posh-client [master +0 ~1 -0]> Get-GitStatusCacheStatistics
	
	Version                        : 1
	Uptime                         : 00:05:11
	TotalGetStatusRequests         : 85
	AverageMillisecondsInGetStatus : 0.572932
	MinimumMillisecondsInGetStatus : 0.248636
	MaximumMillisecondsInGetStatus : 4.204662
	CacheHits                      : 75
	CacheMisses                    : 10
	EffectiveCachePrimes           : 1
	TotalCachePrimes               : 7
	EffectiveCacheInvalidations    : 10
	TotalCacheInvalidations        : 77
	FullCacheInvalidations         : 0
