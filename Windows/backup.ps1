# Prompt for creds
$username = Read-Host "Username"
$pass = Read-Host "Password" -AsSecureString

# Check if MySQL is installed 
if (-not (Get-Command "mysql" -ErrorAction SilentlyContinue)) {
	Write-Host "MySQL is not insalled, installing it now."

	# Install Chocolatey (if not already installed)
	if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
	    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	}
	
	# Install MySQL Server using Chocolatey
	choco install mysql -y
	
	# Start MySQL service
	Start-Service MySQL
	
	# Display MySQL service status
	Get-Service MySQL
}
else {
	# Get MySQL Version
	$version = & mysql --version | ForEach-Object { $_.Split(" ")[4] }
	Write-Host "MySQL is already installed, the version is $version."
}

# Set dump directory
$DUMP_DIR = Join-Path $env:USERPROFILE "backups\sql"
New-Item -ItemType Directory -Path $DUMP_DIR -Force

# Dump all databases
Write-Host "Dumping all databases"
& mysqldump -u $username -p$pass --all-databases | Out-File -FilePath "$DUMP_DIR\all_databases.sql" -Encoding UTF8

# Prompt to install MySQL Workbench
$choice = Read-Host "Would you like to install MySQL Workbench? (yes/no)"
if ($choice -eq "yes") {
	# Install MySQL Workbench using Chocolatey
	choco install mysql.workbench -y
	
	# Output installation completed message
	Write-Host "MySQL Workbench installation completed."
}
