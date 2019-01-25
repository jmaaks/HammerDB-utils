# Settings
$HammerDBResults = "./HammerDBResults.txt"
$HammerDBRunlog = "./HammerDBRuns.txt"

# Get list of HammerDB virtual machines, ignoring any lines that begin with #
$hostnames = (Get-Content "./hostnames.txt") -notmatch '^#'

$line = (Get-Date).ToString() + " - Parsing HammerDB Logs"
Add-Content -Path $HammerDBRunlog $line

# Create consolidated HammerDB results file if it doesn't exist
if (-Not (Test-Path $HammerDBResults)) {
	Set-Content -Path $HammerDBResults "hostname,TIMEDATE,USERS,TPM,NOPM"
}

# Parse through each HammerDB VM's results
foreach ($hostname in $hostnames)
{
	Add-Content -Path $HammerDBRunlog "$hostname : Enabled"
}

# HammerDB Log Format:
#Vuser 1:Test complete, Taking end Transaction Count.
#Timestamp 1 @ Fri Jan 18 12:15:37 MST 2019
#Vuser 1:10 Active Virtual Users configured
#Timestamp 1 @ Fri Jan 18 12:15:37 MST 2019
#Vuser 1:TEST RESULT : System achieved 60501 SQL Server TPM at 13207 NOPM


# Parse through each HammerDB VM's results
foreach ($hostname in $hostnames)
{
	$file = "\\$hostname\C$\hammerdb.log"

	if (Test-Path $file)
	{
		# Read remote file
		$loglines = (Get-Content $file)

		# Find lines containing "Test complete" and get it and next 4 lines
		$ResultsLine = Get-Content $file | Select-String -Pattern "Test complete" -AllMatches -Context 0, 4
		$NumTests = $ResultsLine.count

		foreach ($line in $ResultsLine)
		{
			$Timestamp = ""
			$NumUsers = ""
			$TPM = ""
			$NOPM = ""

			$found = $line -match "Timestamp 1 @ (?<content>.*) "
			if ($found)
			{	
				$Timestamp = $matches['content']
			}

			$found = $line -match ":(?<content>.*) Active Virtual Users"
			if ($found)
			{	
				$NumUsers = $matches['content']
			}

			$found = $line -match "System achieved (?<content>.*) SQL Server"
			if ($found)
			{	
				$TPM = $matches['content']
			}

			$found = $line -match "at (?<content>.*) NOPM"
			if ($found)
			{	
				$NOPM = $matches['content']
			}

			Add-Content -Path $HammerDBResults "$hostname,$Timestamp,$NumUsers,$TPM,$NOPM"

		}

		Add-Content -Path $HammerDBRunlog "$hostname : $NumTests results logged"
	}
	else
	{
		# Write-Host "$hostname : cannot read $HammerDBLog"
		Add-Content -Path $HammerDBRunlog "$hostname : cannot read $HammerDBLog"
	}
}
