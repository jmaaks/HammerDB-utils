# HammerDB-utils
Various Powershell scripts to help with automating various aspects of using HammerDB with SQL Server

Scripts
- GetSQLVersion.ps1
- SQLConfig.ps1
- SQLConfig2.ps1
- ParseResults.ps1

Example output in HammerDBResults.txt:

hostname,TIMEDATE,USERS,TPM,NOPM
hmrdb-sqltst1,Fri Jan 18 12:15:37 MST,10,60501,13207
hmrdb-sqltst1,Fri Jan 18 14:25:30 MST,10,62428,13552
hmrdb-sqltst1,Fri Jan 18 15:03:17 MST,10,63033,13684
hmrdb-sqltst1,Fri Jan 18 15:31:19 MST,20,76890,16763

Example output in HammerDBRuns.txt

1/18/2019 5:26:24 PM - Parsing HammerDB Logs
hmrdb-sqltst1 : Enabled
hmrdb-sqltst1 : 4 results logged
