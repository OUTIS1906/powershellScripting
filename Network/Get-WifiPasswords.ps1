function Get-WifiPasswords {

    [System.Threading.Thread]::CurrentThread.CurrentCulture = 'en-US'
    [System.Threading.Thread]::CurrentThread.CurrentUICulture = 'en-US'

    Write-Progress -Activity "Getting Wi-Fi profiles..." -Status "Retrieving profiles..." -PercentComplete 0

    $wlanProfiles = & netsh wlan show profiles

    $profileNames = $wlanProfiles | Select-String "\:(.+)$" | ForEach-Object {
        $_.Matches.Groups[1].Value.Trim()
    }

    $totalProfiles       = $profileNames.Count
    $currentProfileIndex = 0

    $passwords = foreach ($name in $profileNames) {

        $currentProfileIndex++
        $progressPercent = ($currentProfileIndex / $totalProfiles) * 100
        Write-Progress -Activity "Getting Wi-Fi profiles..." -Status "Retrieving passwords..." -PercentComplete $progressPercent

        $profileInfo = & netsh wlan show profile name="$name" key=clear
        $password = $profileInfo | Select-String "Key Content\W+\:(.+)$" | ForEach-Object {
            $_.Matches.Groups[1].Value.Trim()
        }
        
        [PSCustomObject]@{
            PROFILE  = $name
            PASSWORD = $password
        }
    }

    Write-Progress -Activity "Getting Wi-Fi profiles..." -Status "Completed" -Completed

    $passwords | Format-Table -AutoSize
} 

# Example usage:
# Get-WifiPasswords
