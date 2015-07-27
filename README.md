# git-status-cache-posh-client #

PowerShell client for retrieving git repository information from [git-status-cache](https://github.com/cmarcusreid/git-status-cache). Communicates with the cache process via named pipe. 

## TODO ##

**This project is a work-in-progress.**

Major remaining work:

- Installation script to register module with profile.
- Start cache process automatically.

## Setup ##

Register `GitStatusCachePoshClient.psm1` with `Import-Module` to make the `Get-GitStatusFromCache` command available.

	D:\git-status-cache-posh-client [master +1 ~0 -0 !]> Get-Module GitStatusCachePoshClient

	ModuleType Version    Name                                ExportedCommands
	---------- -------    ----                                ----------------
	Script     0.0        GitStatusCachePoshClient            Get-GitStatusFromCache

##Usage##

Sample output:

	D:\git-status-cache-posh-client [master +1 ~1 -0 !]> Get-GitStatusFromCache
	
	Version           : 1
	Path              : D:\git-status-cache-posh-client
	RepoPath          : D:/git-status-cache-posh-client/.git/
	State             : {}
	Branch            : master
	Upstream          : origin/master
	AheadBy           : 0
	BehindBy          : 0
	IndexAdded        : {}
	IndexModified     : {}
	IndexDeleted      : {}
	IndexTypeChange   : {}
	IndexRenamed      : {}
	WorkingAdded      : {README.md}
	WorkingModified   : {GitStatusCachePoshClient.psm1}
	WorkingDeleted    : {}
	WorkingTypeChange : {}
	WorkingRenamed    : {}
	WorkingUnreadable : {}
	Ignored           : {}
	Conflicted        : {}