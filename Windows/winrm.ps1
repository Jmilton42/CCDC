Set-ExecutionPolicy -ExecutionPolicy Bypass -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LocalAccountTokenFilterPolicy" -Value 1 -Type DWORD -Force
Enable-PSRemoting -Force -SkipNetworkProfileCheck