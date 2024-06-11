function Remove-UserProfile {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Hostname = $env:COMPUTERNAME
    )
    
    $excludedProfilesArray = @(
        # built-in:
        "Administrator",
        "All Users",
        "Default",
        "Default User",
        "Defaultuser0",
        "Public",
        "Wdagutilityaccount",

        # laps:

        # extras: 
        "RunAsTool"
    )
    
    try {
        Get-WmiObject -Class Win32_UserProfile -ComputerName $Hostname -ErrorAction Stop 2>&1 > $null
    }
    catch {
        throw "Remote WMI: falied to connect to $hostname."
    }

    # CIM remote is usually not-allowed
    # [Collections.Generic.List[CimInstance]]$localAvailableProfiles = Get-CimInstance -Query 'SELECT * FROM Win32_UserProfile WHERE (Special = False) AND (Loaded = False)'
    # $allowRemove = [Collections.Generic.Queue[CimInstance]]::new()

    # Remote WMI is
    [Collections.Generic.List[psobject]]$localAvailableProfiles = Get-WmiObject -Query 'SELECT * FROM Win32_UserProfile WHERE (Special = False) AND (Loaded = False)' -ComputerName $Hostname
    $allowRemove = [Collections.Generic.Queue[psobject]]::new()

    foreach ($account in $localAvailableProfiles) {

        $usernameTrim = $account.LocalPath.Split('\')[-1]
        if(($excludedProfilesArray -inotcontains $usernameTrim)) {

            $choice = $Host.UI.PromptForChoice("Confirm:", "> "+ $usernameTrim, ("&Yes", "&No"), 1)

            if ($choice -eq 0) {
                $allowRemove.Enqueue($account)
            }
        }
    }

    if ($allowRemove.Count -le 0) {
        Write-Warning "No account to remove."; return
    }

    $counter    = 1
    $totalTasks = $allowRemove.Count

    Write-Host "`nDeleting...`n"
    while ($allowRemove.Count -gt 0) {

        $taskProcess  = $allowRemove.Dequeue() 
        $usernameTrim = $taskProcess.LocalPath.Split('\')[-1]

        # right-align coutner and % stack
        $proc = [math]::round((($counter / $totalTasks) * 100),1)
        $text = "{0}{1}/{2} {3}%" -f (" " * ($Host.UI.RawUI.BufferSize.Width - 20 )),$counter,$totalTasks,$proc

        $progressParams = @{
            Activity         = "Removing Account"
            Status           =  $text 
            PercentComplete  = ($counter / $totalTasks) * 100
            CurrentOperation = ("processing: {0}" -f $usernameTrim) 
        }

        Write-Progress @progressParams
        Start-Sleep -Seconds 1

        try {
            # CIM !
            # $taskProcess | Remove-WmiObject -ErrorAction Stop -EnableAllPrivileges
            # $taskProcess | Remove-CimInstance -ErrorAction Stop

            # WMI
            $taskProcess.Delete()
            "[+] - Account delete succes: {0}" -f $usernameTrim
         
        }
        catch {
            "[-] - Account delete failed: {0}" -f $usernameTrim
        }
        $counter++
    }
        Write-Progress -Completed -Activity "Removing Account" 
        #$outputObject | format-table -HideTableHeaders
}

# Example usage: 
# Remove-UserProfile
# Remove-UserProfile -Hostname REMOTE-PC
