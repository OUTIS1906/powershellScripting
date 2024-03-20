Function Uninstall-Applications {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory          = $true,
            HelpMessage        = "Enter application keyword.",
            Position           = 0,
            ValueFromPipeline  = $true
        )]
        [string]$ApplicationName,
    
        [Parameter(
            Mandatory        = $false,
            HelpMessage      = "Specify if you want to output in GridView format."
        )]
        [switch]$OutGridView = $false,

        [Alias('Passive')]
        [Parameter(
            Mandatory        = $false,
            HelpMessage      = "Specify if you want to uninstall MSI in massive mode."
        )]
        [switch]$MsiPassive

    )

    [console]::Clear()
    try{[System.Console]::SetWindowPosition(0,[System.Console]::CursorTop)}catch{}
    $delimater = ('-') *($Host.UI.RawUI.WindowSize.Width)
    $counter   = 0

    $delimater
    "Application Uninstaller:"

    $UninstallKeys = @(
        "registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\",
        "registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\"
    )
    
    if (([System.Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')) {
        $UninstallKeys += "registry::HKEY_USERS\S*\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
    }
    else{
        $UninstallKeys += "registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
    }
    
    $UninstallKeys = $UninstallKeys | Get-ChildItem -Force -Recurse
    
    
    $ApplicationsFound = $UninstallKeys | Get-ItemProperty | Where-Object { $_.DisplayName -like "$ApplicationName" } | Select-Object -Property DisplayName, Publisher, DisplayVersion, UninstallString, InstallDate

    if ($null -eq $ApplicationsFound) {
        #Write-Warning "None application matching criteria: $ApplicationName" 
        Write-Host "`nNone application matching criteria: $ApplicationName" -ForegroundColor Yellow
        $delimater
    }
    else{
        
        if($PSBoundParameters.ContainsKey('OutGridView')) {
            $ApplicationsFound = $ApplicationsFound | Out-GridView -OutputMode Multiple -Title "Select applications:"
        }
        else{
            $ApplicationsFound | Format-List  -GroupBy Publisher
            #$ApplicationsFound | Format-Table -GroupBy Publisher
        }

        $Choices = @(
            [System.Management.Automation.Host.ChoiceDescription]::new('&Yes',"Remove application")
            [System.Management.Automation.Host.ChoiceDescription]::new('&No',"Don't remove")
            [System.Management.Automation.Host.ChoiceDescription]::new('&Try again',"Try again")
            [System.Management.Automation.Host.ChoiceDescription]::new('&Show string',"Show uninstall string")
        )

        #try{[System.Console]::SetWindowPosition(0,[System.Console]::CursorTop)}catch{}
        $delimater

        foreach ($application in $ApplicationsFound) {

            if($null -eq $application.uninstalling){
                # remove [yes] from removing choice
            }

            
            $decision = $Host.UI.PromptForChoice("[$counter] Shall we?:", $application.DisplayName, $Choices, 0)
            $counter++

            switch ($decision){
                0 {
                    if($null -ne $application.UninstallString){
                        
                        # for MSI installers
                        if ($application.UninstallString.StartsWith('MsiExec.exe')) {

                            $uid       = [regex]::Matches($application.UninstallString, '\{[A-Fa-f0-9]{8}-([A-Fa-f0-9]{4}-){3}[A-Fa-f0-9]{12}\}').Value
                            $arguments = "/X $uid" 
                            $arguments = if($PSBoundParameters.ContainsKey('MsiPassive')){ "/X $uid /passive"}else {"/X $uid" } 

                            $processParams = @{
                                FilePath     = "C:\Windows\system32\msiexec.exe"
                                ArgumentList = $arguments
                                Wait         = $true
                                PassThru     = $true
                                ErrorAction  = "Stop"
                            }
 
                            try{
                                $exitCode  = Start-Process @processParams
                            }
                            catch {
                                Write-Host "`n Process failed to start." -ForegroundColor Red
                            }
                            
                            if($null -ne $exitCode.ExitCode){
                                [PSCustomObject]@{
                                    ExitCode = $exitCode.ExitCode
                                    Message  =  ([ComponentModel.Win32Exception] $exitCode.ExitCode).Message
                                } | Format-Table -HideTableHeaders
                            }
                        }

                        # for EXE installers
                        else {

                            $uninstaller     = $application.UninstallString -replace '^["'']?(.+?\.exe)["'']?.*', '$1'
                            $uninstallParams = ($application.UninstallString -replace '^".*?"\s*', '').Trim() -split '\s+'

                            $processParams = @{
                                FilePath     = $uninstaller 
                                Wait         = $true
                                PassThru     = $true
                                ErrorAction  = "Stop"
                            }
                            
                            if ($uninstallParams) {
                                $processParams.ArgumentList = $uninstallParams
                            }

                            try{
                                $exitCode = Start-Process @processParams
                            }
                            catch{
                                Write-Host "`n Process failed to start." -ForegroundColor Red
                            }
                        
                            if($null -ne $exitCode.ExitCode){
                                [PSCustomObject]@{
                                    ExitCode = $exitCode.ExitCode
                                    Message  =  ([ComponentModel.Win32Exception] $exitCode.ExitCode).Message
                                } | Format-Table -HideTableHeaders
                            }
                        }
                    }
                    else{
                        #Write-Warning "$($application.DisplayName) uninstallstring doesn't exist"
                        Write-Host "`n" $application.DisplayName "uninstallstring doesn't exist." -ForegroundColor DarkRed

                    }
                    
                }
                1 { "`n Skippig..." }
                2 { Uninstall-Applications } # re-do
                3 { 
                    if($null -ne $application.UninstallString){
                        Write-Host "`n" $application.UninstallString -ForegroundColor Yellow
                    }
                    else {
                        Write-Host "`n" "Uninstalling string is empty!" -ForegroundColor DarkRed
                    }
                }
            }
            $delimater
        }
    }
} Uninstall-Applications
