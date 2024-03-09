param(
    [Parameter(Mandatory=$false)]
    [String]$P1,

    [Parameter(Mandatory=$false)]
    [String]$P2,

    [Parameter(Mandatory=$false)]
    [String[]]$Exclude = @("")
)
$Error.Clear()
$ErrorActionPreference = "Continue"

Write-Output "#########################"
Write-Output "#                       #"
Write-Output "#         Users         #"
Write-Output "#                       #"
Write-Output "#########################"

Write-Output "#########################"
Write-Output "#    Hostname/Domain    #"
Write-Output "#########################"
Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem | Select-Object Name, Domain
Write-Output "#########################"
Write-Output "#          IP           #"
Write-Output "#########################"
Get-WmiObject Win32_NetworkAdapterConfiguration | ? {$_.IpAddress -ne $null} | % {$_.ServiceName + "`n" + $_.IPAddress + "`n"}
$DC = $false
if (Get-WmiObject -Query "select * from Win32_OperatingSystem where ProductType='2'") {
    $DC = $true
    Write-Output "$Env:ComputerName [INFO] Domain Controller"
}

if($DC){
    $CurrentADUsers = Get-ADGroupMember -Identity "Domain Users" | Select-Object -ExpandProperty name
    foreach($user in $CurrentADUsers){
        if($Exclude -notcontains $user){
            try{
                Set-ADAccountPassword -Identity $user -NewPassword (ConvertTo-SecureString -AsPlainText $P1 -Force) -Reset
            }
            catch{
                Write-Output "[ERROR] Failed to change password for user $user, disabling account"
                Disable-ADAccount -Identity $user
            }
        }
    }

    try{
        $userExists = Get-ADUser -Filter {SamAccountName -eq "ttuccdc"}
        if($userExists){
            Set-ADAccountPassword -Identity "ttuccdc" -NewPassword (ConvertTo-SecureString -AsPlainText $P2 -Force) -Reset
        } else {
            New-ADUser -Name "ttuccdc" -AccountPassword (ConvertTo-SecureString -AsPlainText $P2 -Force) -Enabled $true
        }
        Add-ADGroupMember -Identity "Administrators" -Members "ttuccdc"
        Add-ADGroupMember -Identity "Remote Desktop Users" -Members "ttuccdc"
        Add-ADGroupMember -Identity "Domain Admins" -Members "ttuccdc"
    }
    catch{
        Write-Output "[ERROR] Failed to create user ttuccdc"
        Set-ADAccountPassword -Identity "Administrator" -NewPassword (ConvertTo-SecureString -AsPlainText $P2 -Force) -Reset
        Enable-ADAccount -Identity "Administrator"
    }
} else {
    $CurrentUsers = Get-LocalUser | Select-Object -ExpandProperty name
    foreach($user in $CurrentUsers){
        if($Exclude -notcontains $user){
            try{
                Set-LocalUser -Name $user -Password (ConvertTo-SecureString -AsPlainText $P1 -Force) -AccountNeverExpires
            }
            catch{
                Write-Output "[ERROR] Failed to change password for user $user, disabling account"
                Disable-LocalUser -Name $user
            }
        }
    }

    try{
        $userExists = Get-LocalUser -Name "ttuccdc"
        if($userExists){
            Set-LocalUser -Name "ttuccdc" -Password (ConvertTo-SecureString -AsPlainText $P2 -Force) -AccountNeverExpires
        } else {
            New-LocalUser -Name "ttuccdc" -Password (ConvertTo-SecureString -AsPlainText $P2 -Force) -AccountNeverExpires
        }
        Add-LocalGroupMember -Group "Administrators" -Member "ttuccdc"
        Add-LocalGroupMember -Group "Remote Desktop Users" -Member "ttuccdc"
    }
    catch{
        Write-Output "[ERROR] Failed to create user ttuccdc"
        Set-LocalUser -Name "Administrator" -Password (ConvertTo-SecureString -AsPlainText $P2 -Force)
        Set-LocalUser -Name "Administrator" -AccountNeverExpires
    }
}