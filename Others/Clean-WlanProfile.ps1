Function Clean-WlanProfile{
    
    $commandOutput = netsh wlan show profiles
    $pattern = 'All User Profile\s+:\s+(.*)'
    $matches = [regex]::Matches($commandOutput, $pattern)
    
    $profileNames = @()
    
    foreach ($match in $matches) {
        $profileNames += $match.Groups[1].Value
    }
    
    if($profileNames.Count -gt 0){
        $RemoveProfiles = $profileNames | Out-GridView -Title "Select profiles to remove" -OutputMode Multiple
    
        foreach($item in $RemoveProfiles){
            netsh wlan delete profile name=$item
            Get-ChildItem -Path "registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles" | Get-ItemProperty  | Where-Object {$_.Profilename -eq $item.trim() } | Remove-Item -Force -Recurse
        }
    }
}Clean-WlanProfile
