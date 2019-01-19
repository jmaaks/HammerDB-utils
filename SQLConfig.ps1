##############################################
# Checking to see if the SqlServer module is already installed, if not installing it
##############################################
$SQLModuleCheck = Get-Module -ListAvailable SqlServer
if ($SQLModuleCheck -eq $null)
{
write-host "SqlServer Module Not Found - Installing"
# Not installed, trusting PS Gallery to remove prompt on install
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
# Installing module, requires run as admin for -scope AllUsers, change to CurrentUser if not possible
Install-Module -Name SqlServer –Scope AllUsers -Confirm:$false -AllowClobber
}
##############################################
# Importing the SqlServer module
##############################################
Import-Module SqlServer

# SQL Instance connection info
$SQLInstance = "(local)"
$SQLDatabase = "master"
$SQLUsername = "sa"
$SQLPassword = "password"

# Configure SQL Server settings
write-host "Configuring SQL Server"
$SQLQuery1 = "exec sp_configure 'show advanced options', '1'
reconfigure with override
exec sp_configure 'min server memory', 8192
exec sp_configure 'max server memory', 16384
exec sp_configure 'recovery interval','32767'
exec sp_configure 'max degree of parallelism','1'
exec sp_configure 'lightweight pooling','1'
exec sp_configure 'priority boost', '1'
exec sp_configure 'max worker threads', 3000
exec sp_configure 'default trace enabled', 0
go
reconfigure with override"

$SQLQuery1Output = invoke-sqlcmd -query $SQLQuery1 -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword -verbose
write-host "Results: $SQLQuery1Output"

# Create F:\TempDB directory
write-host "Creating F:\TempDB"
new-item F:\TempDB -itemtype directory

# Update TempDB file locations
write-host "Moving default TempDB files to F:\TempDB"
$SQLQuery2 = "USE [master]; 
GO 
ALTER DATABASE tempdb
MODIFY FILE (NAME = tempdev, FILENAME = 'F:\TempDB\tempdb.mdf');
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = templog, FILENAME = 'F:\TempDB\templog.ldf');
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = temp2, FILENAME = 'F:\TempDB\tempdb_mssql_2.ndf');
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = temp3, FILENAME = 'F:\TempDB\tempdb_mssql_3.ndf');
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = temp4, FILENAME = 'F:\TempDB\tempdb_mssql_4.ndf');
GO"

$SQLQuery2Output = invoke-sqlcmd -query $SQLQuery2 -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword -verbose
write-host "Results: $SQLQuery2Output"

# Restart SQL Server
write-host "Now restart SQL Server and then run SQLConfig2.ps1"

