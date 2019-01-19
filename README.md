# HammerDB-utils
Powershell scripts to help with automating various aspects of using HammerDB to run benchmark tests against SQL Server.

# GetSQLVersion.ps1
Simply tests connectivity to the SQL Server instance (mainly for easy troubleshooting).

# SQLConfig.ps1
This script performs the following tasks:
- Sets SQL Server settings for HammerDB
- Moves TempDB files from C: to F:

At this point SQL Server (or the VM) needs to be restarted to move the TempDB files (since if we resize them now SQL Server tries to resize them on C:).

# SQLConfig2.ps1
This script picks up where SQLConfig.ps1 left off to:
- Resize the default 4 TempDB database files and log to 8GB
- Add 4 additional TempDB database files
- Attach the tpcc database
- Configure the tpcc database
- Add sp_CPUSIMPLE stored procedure

# ParseResults.ps1
This script aggregates HammerDB TPC-C benchmark results (as logged in C:\hammerdb.log) from multiple SQL Server instances into a single comma-delimited results file.

## Sample HammerDBResults.txt
```
hostname,TIMEDATE,USERS,TPM,NOPM
hmrdb-sqltst1,Fri Jan 18 12:15:37 MST,10,60501,13207
hmrdb-sqltst1,Fri Jan 18 14:25:30 MST,10,62428,13552
hmrdb-sqltst1,Fri Jan 18 15:03:17 MST,10,63033,13684
hmrdb-sqltst1,Fri Jan 18 15:31:19 MST,20,76890,16763
```

## Sample HammerDBRuns.txt
```
1/18/2019 5:26:24 PM - Parsing HammerDB Logs
hmrdb-sqltst1 : Enabled
hmrdb-sqltst1 : 4 results logged
```

# References
## HammerDB
- [HammerDB website](https://www.hammerdb.com/)
- [HammerDB on SourceForge](https://sourceforge.net/projects/hammerdb/) (for source code, support discussion board, etc.)
- [HammerDB Best Practice for SQL Server Performance and Scalability](https://www.hammerdb.com/blog/uncategorized/hammerdb-best-practice-for-sql-server-performance-and-scalability/)

## SQL Server Best Practices & Performance Tuning
- [BrentOzar.com](https://www.brentozar.com/)
  - [SQL Server Perfmon (Performance Monitor) Best Practices](https://www.brentozar.com/archive/2006/12/dba-101-using-perfmon-for-sql-performance-tuning/)
