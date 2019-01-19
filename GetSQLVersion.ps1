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
$SQLPassword = "Axellio@1"

# Check SQL Server version
write-host "Getting SQL Server version"
$SQLQuery1 = "select @@version"

$SQLQuery1Output = (invoke-sqlcmd -query $SQLQuery1 -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword -verbose)
write-output $SQLQuery1Output

