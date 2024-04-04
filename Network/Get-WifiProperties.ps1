Function Get-WifiProperties {

    [System.Threading.Thread]::CurrentThread.CurrentCulture   = 'en-US'
    [System.Threading.Thread]::CurrentThread.CurrentUICulture = 'en-US'
    
    $showInterface = & netsh wlan show interface

    $psObject = [PSCustomObject]@{}
    
    foreach ($line in $showInterface) {
            
        $pattern = "^\s*([a-zA-Z\s-]+)\s*:\s*(.*?)\s*$"
        $matches = [regex]::Matches($line, $pattern)
    
        if ($matches.Success) {
    
            $key   = $matches.Groups[1].Value.Trim()
            $value = $matches.Groups[2].Value.Trim()
    
            $psObject | Add-Member -MemberType NoteProperty -Name $key -Value $value
        }
    }

    return $psObject
}

# Example usage:
# Get-WifiProperties
