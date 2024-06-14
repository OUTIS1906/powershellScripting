function Get-WindowsCredentials {
    
    $outputObject = (& cmdkey.exe /list 2>&1) -join "`n"
    $pattern      = "Target:\s*(.*?)\r?\n\s*Type:\s*(.*?)\r?\n\s*User:\s*(.*?)\r?\n"

    $matches = [regex]::Matches($outputObject, $pattern)
    
    $credObject = foreach ($match in $matches) {
        [PSCustomObject]@{
            Target = $match.Groups[1].Value
            User   = $match.Groups[3].Value
            Type   = $match.Groups[2].Value
        }
    }
    return $credObject
}

# Example usage:
# Get-WindowsCredentials

function Remove-WindowsCredentials {

    $outputObject = (& cmdkey.exe /list 2>&1) -join "`n"
    $pattern      = "Target:\s*(.*?)\r?\n\s*Type:\s*(.*?)\r?\n\s*User:\s*(.*?)\r?\n"

    $matches = [regex]::Matches($outputObject, $pattern)
    
    $credObject = foreach ($match in $matches) {
        [PSCustomObject]@{
            Target = $match.Groups[1].Value
            User   = $match.Groups[3].Value
            Type   = $match.Groups[2].Value
        }
    }

    foreach ($item in $credObject | Out-GridView -OutputMode Multiple) {
        & cmdkey.exe /del $item.Target  2>&1
    }
}

# Example usage:
# Remove-WindowsCredentials
