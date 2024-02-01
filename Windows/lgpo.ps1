$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $false) {
    Write-Warning "Please run as administrator."
    exit 1
}

# backup
New-Item -ItemType Directory -Force -Path "$PWD\backup"
New-Item -ItemType Directory -Force -Path "$PWD\gpo"
& $PWD\LGPO.exe /b "$PWD\backup"
# & $PWD\LGPO.exe g "$PWD\gpo"

Expand-Archive -Path "$env:USERPROFILE\Downloads\gpo.zip" -DestinationPath "$env:USERPROFILE\Downloads\gpo" -Force
Move-Item -Path "$env:USERPROFILE\Downloads\gpo\DoD Google Chrome v2r8" -Destination "$PWD\gpo\Chrome" -Force
Move-Item -Path "$env:USERPROFILE\Downloads\gpo\DoD Internet Explorer 11 v2r5" -Destination "$PWD\gpo\IE" -Force
Move-Item -Path "$env:USERPROFILE\Downloads\gpo\DoD Microsoft Defender Antivirus STIG v2r4" -Destination "$PWD\gpo\Defender_AV" -Force
Move-Item -Path "$env:USERPROFILE\Downloads\gpo\DoD Microsoft Edge v1r7" -Destination "$PWD\gpo\Edge" -Force
Move-Item -Path "$env:USERPROFILE\Downloads\gpo\DoD Mozilla Firefox v6r5" -Destination "$PWD\gpo\Firefox" -Force

# Determine Windows version
$os = (Get-WmiObject -class Win32_OperatingSystem).Caption

# Check if $os has 'Server' and '2012' in it
if ($os -match 'Server' -and $os -match '2012') {
    Move-Item -Path "$env:USERPROFILE\Downloads\gpo\DoD WinSvr 2012 R2 MS and DC v3r7" -Destination "$PWD\gpo\WinSvr_2012" -Force
} elseif ($os -match 'Server' -and $os -match '2016') {
    Move-Item -Path "$env:USERPROFILE\Downloads\gpo\DoD WinSvr 2016 MS and DC v2r7" -Destination "$PWD\gpo\WinSvr_2016" -Force
} elseif ($os -match 'Server' -and $os -match '2019') {
    Move-Item -Path "$env:USERPROFILE\Downloads\gpo\DoD WinSvr 2019 MS and DC v2r8" -Destination "$PWD\gpo\WinSvr_2019" -Force
} elseif ($os -match 'Server' -and $os -match '2022') {
    Move-Item -Path "$env:USERPROFILE\Downloads\gpo\DoD WinSvr 2022 MS and DC v1r4" -Destination "$PWD\gpo\WinSvr_2022" -Force
} elseif ($os -match 'Windows 10') {
    Move-Item -Path "$env:USERPROFILE\Downloads\gpo\DoD Windows 10 v2r8" -Destination "$PWD\gpo\Win10" -Force
} elseif ($os -match 'Windows 11') {
    Move-Item -Path "$env:USERPROFILE\Downloads\gpo\DoD Windows 11 v1r5" -Destination "$PWD\gpo\Win11" -Force
} else {
    Write-Warning "Cannot determine Windows version. Skipping OS GPOs."
}

& $PWD\LGPO.exe /g "$PWD\gpo\"
