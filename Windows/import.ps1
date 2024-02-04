# Prompt for creds
$username = Read-Host "Username"
$pass = Read-Host "Password" -AsSecureString

# Set dump directory
$DUMP_DIR = Join-Path $env:USERPROFILE "backups\sql"

# Importing all databases
Write-Host "Importing all databases"
$process = Start-Process -FilePath "mysql" -ArgumentList "-u", $username, "-p$pass", "<", "$DUMP_DIR\all_databases.sql" -Wait

# Checking if the command successfully ran
if ($process.ExitCode -eq 0) {
	Write-Host "Command ran successfully."
}
else {
	Write-Host "Comamnd failed. Exit code: $($process.ExitCode)"
}