param($file, $ShowError)



# Import csv file
$csvfile = Import-Csv -Path $file
$UsersToMake = @()
    
write-host "`n"

# Number of successfull password changes
$successes = $csvfile.Count


# determine if uer wants errors to be shown or not
if(!($ShowError -eq "--showerrors")){
    $ErrorActionPreference = 'silentlycontinue'
}

#import csv file with only names
$UsersOnly = Import-csv -Path $file | Select-Object -ExpandProperty user

#declare array to hold mismatched users
$mismatch = @()

#get the current list of users
$CurrentUsers = Get-LocalUser | Select-Object -ExpandProperty name

#get the current list of Domain Users
$CurrentADUsers = Get-ADGroupMember -Identity "Domain Users" | Select-Object -ExpandProperty name



$chooseLocal = Read-Host "Would you like to audit Local (1) or Active Directory (2) users?"

Write-Host `n -NoNewline

if ($chooseLocal -eq "1"){


    # for each row in csvfile
    ForEach($i in $csvfile){
    
        #if user currently exists
        if(($CurrentUsers -contains $i.User) -and ($i.Password -ne "N/A")){
            # perform password change
            Net User $i.User $i.Password | Out-Null2
            Add-LocalGroupMember -Group "Users" -Member $i.User | Out-Null         

            if (($i.IsAdmin -eq "normal") -and ((Get-LocalGroupMember -Group "Administrators" -Member $i.User) -like "*\$i.User")){
                
                Remove-LocalGroupMember -Group "Administrators" -Member $i.User | Out-Null
                write-host $i.User " is not supposed to be an admin!!!!"
            }

            if (($i.IsAdmin -eq "admin") -and !((Get-LocalGroupMember -Group "Administrators" -Member $i.User) -like "*\$i.User")){
                
                Add-LocalGroupMember -Group "Administrators" -Member $i.User | Out-Null
                write-host $i.User " has been promoted to admin."
            }

            write-host "Successfully" -foreground green -nonewline 
            write-host " updated the password for" $i.User
        }

        #if user has no password provided
        elseif($i.password -eq "N/A"){
    
            write-host "ERROR:" -foreground red -nonewline
            write-host " The user" $i.User "has no password supplied"
        }
        # else command failed or no user exists
        else{
            # print error message and decrement successes
            write-host "ERROR:" -foreground red -nonewline
            write-host " The user" $i.User "may not exist"
            $successes--
            $UsersToMake += $i
        }
    
    }
    
    # print out total number of successes 
    write-host "`nSUCCESSFULLY" -foreground green -nonewline 
    write-host " processed" $successes "out of" $csvfile.Count "users."


    #if there exists users on the csv but not on the system
    if($successes -ne $csvfile.Count){
    
        #for each non-existent user
        foreach($i in $UsersToMake){

            if(!($CurrentUsers -contains $i.User)){
                # query user choice
                $decision = read-host "`nWould you like to add the non-existent user" $i.User "to the system: y/n" 

                # if "y" or "Y"
                if(($decision -eq "y") -or ($decision -eq "Y")){
        
                            $secure = ConvertTo-SecureString -String $i.Password -AsPlainText -Force
                            New-LocalUser $i.User -Password $secure | Out-Null
                            Add-LocalGroupMember -Group "Users" -Member $i.User | Out-Null

                            if($i.IsAdmin -eq "admin"){
                                
                                Add-LocalGroupMember -Group "Administrators" -Member $i.User | Out-Null
                            }
                    }
              
                else{
                    continue
                }
            }
        }
        

            write-host "`nSUCCESSFULLY" -foreground green -nonewline 
            write-host " processed the selected users."
    }

    


    #for every current user
    foreach($element in $CurrentUsers){
    
        #check if they exist in the csv file and add to mismatched accordingly
        if(!($UsersOnly -contains $element)){
           $mismatch += $element
        }
    
    }

    #if there exists users on the system that are not documented on the csv
    if($mismatch.Count -gt 0){
    
        write-host "`nSome users were found on the system that weren't specified in the csv file`n" -foreground yellow

        #for every mismatched user
        foreach($element in $mismatch){
    

            #query if you want to keep them
            $decision = read-host "Would you like to keep" $element "as a user? y/n"


            #if yes then add name to csv file
            if((($decision -eq "y") -or ($decision -eq "Y")) -and !($UsersOnly -contains $element)){
    
                "{0},{1}" -f $element,"N/A" | add-content -path $file
            }

            #if no then disable them from the system
            else{
                Disable-LocalUser $element
                write-host "SUCCESSFULLY:" -foreground green -NoNewline
                write-host " removed"$element
            }
        }
    }
}
elseif($chooseLocal -eq "2"){
    
    # for each row in csvfile
    ForEach($i in $csvfile){
        

        $Admin_Types = "Schema Admins", "DnsAdmins", "Domain Admins", "Enterprise Admins", "Enterprise Key Admins", "Key Admins"

                 
        foreach($type in $Admin_Types){
                
            
            if (($i.IsAdmin -eq "normal") -and ((Get-ADGroupMember -Identity $type | select-object -expandproperty name) -contains $i.User)){
                    
                $response = read-host "The user "$i.User" is marked as `"normal`" but has the role $type. Would you like to demote them? (y/n)"

                if (($response -eq "y") -or ($response -eq "Y")){
                    Remove-ADGroupMember -Identity $type -Members $i.User | Out-Null
                }
            }

            if (($i.IsAdmin -eq "admin") -and !((Get-ADGroupMember -Identity $type | select-object -expandproperty name) -contains $i.User)){

                $response = read-host "The user " $i.User " is marked as admin but has no privileges, what role would you like to give them? (if none then `'none`')"
                
                if ($response -eq "none"){
                    break
                }

                Add-ADGroupMember -Identity $response -Members $i.User | Out-Null
                write-host $i.User " has been promoted to $response."
                
            }
        }


        #if user currently exists
        if(($CurrentADUsers -contains $i.User) -and ($i.password -ne "N/A")){
            
            Set-ADAccountPassword -Identity $i.User -NewPassword (ConvertTo-SecureString -AsPlainText $i.Password -Force)
            

            write-host "SUCCESSFULLY" -foreground green -nonewline 
            write-host " updated the password for" $i.User
        }

        #if user has no password provided
        elseif($i.password -eq "N/A"){
    
            write-host "ERROR:" -foreground red -nonewline
            write-host " The user" $i.User "has no password supplied"
        }
        # else command failed or no user exists
        else{
            # print error message and decrement successes
            write-host "ERROR:" -foreground red -nonewline
            write-host " The user" $i.User "may not exist"
            $successes--
            $UsersToMake += $i
        }
    
    }
    
    # print out total number of successes 
    write-host "`nSUCCESSFULLY" -foreground green -nonewline 
    write-host " processed" $successes "out of" $csvfile.Count "users."


    #if there exists users on the csv but not on the system
    if($successes -ne $csvfile.Count){
    
        #for each non-existent user
        foreach($i in $UsersToMake){

            if(!($CurrentADUsers -contains $i.User)){
                # query user choice
                $decision = read-host "`nWould you like to add the non-existent user" $i.User "to the system: y/n" 

                # if "y" or "Y"
                if(($decision -eq "y") -or ($decision -eq "Y")){
        
                            $secure = ConvertTo-SecureString -String $i.Password -AsPlainText -Force
                            New-ADUser -name $i.User -AccountPassword $secure -Enabled $true #| Out-Null

                            if($i.IsAdmin -eq "admin"){
                                $response = read-host "The user " $i.User " is marked as admin but has no privileges, what role would you like to give them? (if none then `'none`')"
                                Add-ADGroupMember -Identity $response -Members $i.User
                                write-host $i.User " has been promoted to $response."
                            }
                            
                    }
              
                else{
                    continue
                }
            }
        }
        

            write-host "`nSUCCESSFULLY" -foreground green -nonewline 
            write-host " processed the selected users."
    }

    


    #for every current user
    foreach($element in $CurrentADUsers){
    
        #check if they exist in the csv file and add to mismatched accordingly
        if(!($UsersOnly -contains $element)){
           $mismatch += $element
        }
    
    }

    #if there exists users on the system that are not documented on the csv
    if($mismatch.Count -gt 0){
    
        write-host "`nSome users were found on the system that weren't specified in the csv file`n" -foreground yellow

        #for every mismatched user
        foreach($element in $mismatch){
    

            #query if you want to keep them
            $decision = read-host "Would you like to keep" $element "as a user? y/n"


            #if yes then add name to csv file
            if((($decision -eq "y") -or ($decision -eq "Y")) -and !($UsersOnly -contains $element)){
    
                "{0},{1}" -f $element,"N/A" | add-content -path $file
            }

            #if no then remove them from the system
            else{
                Disable-ADAccount -Identity $element
                write-host "`nSUCCESSFULLY:" -foreground green -NoNewline
                write-host " disabled"$element
            }
        }
    }

}
else {
    
    write-host "`nERROR:" -foreground red -nonewline
    Write-Host "That is not a valid option"
    return
}
write-host "`n`nALL OPERATIONS COMPLETE" -foreground green
