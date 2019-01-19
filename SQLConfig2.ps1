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


# Resize TempDB files
write-host "Resizing TempDB files to 8GB"
$SQLQuery3 = "USE [master]; 
GO 
ALTER DATABASE [tempdb]
MODIFY FILE (NAME = tempdev, SIZE = 8GB, FILEGROWTH = 0);
GO 
ALTER DATABASE [tempdb]
MODIFY FILE (NAME = templog, SIZE = 8GB, FILEGROWTH = 0);
GO 
ALTER DATABASE [tempdb]
MODIFY FILE (NAME = temp2, SIZE = 8GB, FILEGROWTH = 0);
GO
ALTER DATABASE [tempdb]
MODIFY FILE (NAME = temp3, SIZE = 8GB, FILEGROWTH = 0);
GO
ALTER DATABASE [tempdb]
MODIFY FILE (NAME = temp4, SIZE = 8GB, FILEGROWTH = 0);
GO"

$SQLQuery3Output = invoke-sqlcmd -query $SQLQuery3 -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword -verbose

# Add four additional files
write-host "Adding 4 additional TempDB files"
$SQLQuery4 = "USE [master];
GO
ALTER DATABASE [tempdb]
ADD FILE (NAME = temp5, FILENAME = 'F:\TempDB\tempdb_mssql_5.ndf', SIZE = 8GB, FILEGROWTH = 0);
GO
ALTER DATABASE [tempdb]
ADD FILE (NAME = temp6, FILENAME = 'F:\TempDB\tempdb_mssql_6.ndf', SIZE = 8GB, FILEGROWTH = 0);
GO
ALTER DATABASE [tempdb]
ADD FILE (NAME = temp7, FILENAME = 'F:\TempDB\tempdb_mssql_7.ndf', SIZE = 8GB, FILEGROWTH = 0);
GO
ALTER DATABASE [tempdb]
ADD FILE (NAME = temp8, FILENAME = 'F:\TempDB\tempdb_mssql_8.ndf', SIZE = 8GB, FILEGROWTH = 0);
GO"

$SQLQuery4Output = invoke-sqlcmd -query $SQLQuery4 -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword -verbose

# Attach to tpcc1000 database (and rename to spcc)
write-host "Attaching to tpcc database"
$SQLQuery5 = "create database tpcc
on primary (name=tpcc, filename='D:\SQLDB\tpcc1000.mdf')
log on (name=tpcc_log, filename='E:\SQLLog\tpcc1000_log.ldf') for attach;
GO"

# $SQLQuery5Output = invoke-sqlcmd -query $SQLQuery5 -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword -verbose

# Work around weird permission error trying to open the DB files
$LocalUser = ".\Administrator"$LocalPWord = ConvertTo-SecureString -String "password" -AsPlainText -Force$LocalCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $LocalUser, $LocalPWordInvoke-Command -VMName $line.vmname -Credential $LocalCredential -ScriptBlock {invoke-sqlcmd -query $Using:SQLQuery5}

# Configure tpcc database settings
write-host "Configuring tpcc database"
$SQLQuery6 = "alter database tpcc set compatibility_level = 140;
GO
ALTER AUTHORIZATION ON DATABASE::tpcc to sa;
GO
ALTER DATABASE tpcc SET RECOVERY SIMPLE;
GO
ALTER DATABASE tpcc SET TORN_PAGE_DETECTION OFF;
GO
ALTER DATABASE tpcc SET PAGE_VERIFY NONE;
GO"

$SQLQuery6Output = invoke-sqlcmd -query $SQLQuery6 -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword -verbose


# Create Single Threaded Performance test stored procedure
write-host "Creating Single Threaded Performance test stored proceduree"
$SQLQuery7 = "USE [tpcc]
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CPUSIMPLE] 
AS
   BEGIN
      DECLARE
         @n numeric(16,6) = 0,
         @a DATETIME,
         @b DATETIME
      DECLARE
         @f int
      SET @f = 1
      SET @a = CURRENT_TIMESTAMP
      WHILE @f <= 10000000 
         BEGIN
      SET @n = @n % 999999 + sqrt(@f)
            SET @f = @f + 1
         END
         SET @b = CURRENT_TIMESTAMP
         PRINT 'Timing = ' + ISNULL(CAST(DATEDIFF(MS, @a, @b)AS VARCHAR),'')
         PRINT 'Res = ' + ISNULL(CAST(@n AS VARCHAR),'')
   END"

$SQLQuery7Output = invoke-sqlcmd -query $SQLQuery7 -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword -verbose
