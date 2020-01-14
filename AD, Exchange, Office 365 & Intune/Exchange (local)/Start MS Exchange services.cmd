# .SYNOPSIS
# Small cmd script to start all Exchange services on a server after a reboot, in case they did not start automatically.
#
# .AUTHOR 
# Thomas Balder (inspired by others)
# https://github.com/ThomasBalder/PublicScripts 
#
# .DESCRIPTION 
#
#
# .REQUIREMENTS
# - Nothing special other then proper permissions on server
#
#
# .INSTRUCTIONS
# Just start the cmd script in an elevated (administrator) command prompt on an Exchange server;
#

@Echo off
Echo 'Starting Microsoft Exchange Services'
net start MSExchangeAB
net start MSExchangeADTopology
net start MSExchangeAntispamUpdate
net start MSExchangeEdgeSync
net start MSExchangeFBA
net start MSExchangeFDS
net stop MSExchangeIS
net start MSExchangeRPC
net start MSExchangeIS
net start MSExchangeMailboxAssistants
net start MSExchangeMailboxReplication
net start MSExchangeMailSubmission
net start MSExchangeProtectedServiceHost
net start MSExchangeRepl
net start MSExchangeSA
net start MSExchangeSearch
net start MSExchangeServiceHost
net start MSExchangeThrottling
net start MSExchangeTransport
net start MSExchangeTransportLogSearch
End