$parents=@("ncat.exe", "nc.exe", "netcat.exe", "php.exe", "python.exe", "httpd.exe", "w3wp.exe")

while ($true) {
    Get-WmiObject -Class Win32_Process -Filter "name ='cmd.exe' OR name ='powershell.exe' OR name = 'PowerShell_ISE.exe'" | Select-Object ParentProcessId | ForEach-Object {
        $ppid = $_.ParentProcessId
        $pname = Get-CimInstance Win32_Process -Filter "ProcessId = '$ppid'" | Select-Object Name -ExpandProperty Name
        #Write-Host "$ppid"
        #Write-Host "$pname"
        if ($parents -contains $pname) {
            Write-Host "Webshell spawned by $pname detected. Killing PID $pid"
            Stop-Process -Id $pid
        }
    }
}
