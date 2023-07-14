Function Remove-UserProfiles{

    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]$Confirm
    )

    # Create array of excluded profile paths
    [System.Collections.ArrayList]$ExcludedProfiles = @(
        "C:\Users\Administrator",
        "C:\Users\Public",
        "C:\Users\All Users",
        "C:\Users\Default User",
        "C:\Users\Default",
        "C:\Users\RunAsTool",
        'C:\Users\Defaultuser0'
    )

    # Get current usernames from different sources and add them to excluded list
    $CurrentUser = @(
        ((Get-CimInstance -ClassName Win32_ComputerSystem).UserName),
        (Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" -Name "LastLoggedOnUser"),
        ([System.Environment]::UserName)
    ) | ForEach-Object { if(-not[string]::IsNullOrWhiteSpace($_)){$_.Split("\")[-1].ToLower() }}  | Select-Object -Unique

    # Add unique values to Excluded List
    $CurrentUser | ForEach-Object { if(-not[bool]($ExcludedProfiles -match $_ )){$ExcludedProfiles.Add((Join-Path -Path "C:\users" -ChildPath $_ )) | Out-Null }}

    # Query Profiles
    $Profiles2Remove = Get-CimInstance -Query 'SELECT * FROM Win32_UserProfile WHERE (Special = False)' | Where-Object -FilterScript { $_.LocalPath -notin $ExcludedProfiles }

    if($Profiles2Remove.Count -gt 0){

        # Choise box settings
        $ChoiseBox = @{
            title       = 'Removing Account:'
            default     = 1
            question    = $null
            choices     = @(
                [System.Management.Automation.Host.ChoiceDescription]::new('&Yes',"Remove account")
                [System.Management.Automation.Host.ChoiceDescription]::new('&No',"Don't remove")
            )  
        }
        
        Foreach ($User in $Profiles2Remove){

            # Choise question Remove: Account
            $ChoiseBox.question = $User.LocalPath

            if($Host.UI.PromptForChoice($ChoiseBox.title, $ChoiseBox.question, $ChoiseBox.choices, $ChoiseBox.default) -eq 0) {

                # Checking for running process by removing user
                $UsernameLocked = ($User.LocalPath).split("\")[-1]
                $ProcessLocked = Get-Process -IncludeUserName | Where-Object { $_.UserName -match $UsernameLocked }

                # Stopping processess
                if([bool]$ProcessLocked){ $ProcessLocked | Stop-Process -Force -Confirm:$false }

                try{
                    # Removing Account
                    $User | Remove-CimInstance -ErrorAction Stop -Confirm:$($Confirm.IsPresent)
                    
                    # Cleaning Account Path
                    if(Test-Path -Path $User.LocalPath -PathType Any ){ 
                        $User.LocalPath | Remove-Item -Force -Confirm -ErrorAction Stop 
                    }
                }
                catch{
                    write-host "Something went wrong with $($User.LocalPath) -> $($Error[0].Exception.Message)"
                }
            }
            else{
                "Skipping..."
            }
        }
    }
    else{
        Write-Warning "No profiles to be removed"
    }

    Remove-Variable Profiles2Remove ,CurrentUser,ExcludedProfiles, -Force

}Remove-UserProfiles
