Function Get-WiFiNetworks {

    [System.Threading.Thread]::CurrentThread.CurrentCulture = 'en-US'
    [System.Threading.Thread]::CurrentThread.CurrentUICulture = 'en-US'

    $showInterface = & netsh wlan show net mode=bssid | Out-String

    $blockPattern = "(?sm)(SSID \d+ : .+?)(?=SSID \d+ : |\z)"
    $blocks       = [regex]::Matches($showInterface, $blockPattern)

    $networks = @()
    $index  = 0
    
    foreach ($wlan in $blocks) {

        if($wlan.Success){

            $psObject = [PSCustomObject]@{}

            
            $psObject | Add-Member -MemberType NoteProperty -Name "ID" -Value (++$index)-Force

            foreach($item in ($wlan.Value -split "`r?`n").Trim()) {

                $pattern = "^\s*(.+?)\s*:\s*(.*?)\s*$"
                $matches = [regex]::Matches($item, $pattern)

                if ($matches.Success) {

                    $key   = $matches.Groups[1].Value.Trim()
                    $value = $matches.Groups[2].Value.Trim()

                    if($key -match '^SSID \d+') {
                        $key = 'Name'
                    }

                    $psObject | Add-Member -MemberType NoteProperty -Name $key -Value $value -Force
                }
            }
            $networks += $psObject
        }
    }
    return $networks
}

# Example usage:
# Get-WiFiNetworks
# Get-WiFiNetworks | Format-Table -AutoSize
