# Prompt for creds
$username = Read-Host "Username"
$pass = Read-Host "Password" -AsSecureString

# Check if MySQL is installed 
if (-not (Get-Command "mysql" -ErrorAction SilentlyContinue)) {
	Write-Host "MySQL is not insalled, installing it now."

	# Install MySQL
	Start-Process -Filepath "apt" -ArgumentList "update" -Wait
	Start-Process -Filepath "apt" -ArgumentList "install", "-y", "mysql-server" -Wait
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
    Start-Process -FilePath "apt" -ArgumentList "update" -Wait
    Start-Process -FilePath "apt" -ArgumentList "install", "mysql-workbench" -Wait
}