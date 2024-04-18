Function Get-Quser {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Server = $env:COMPUTERNAME,
        [switch]$Logoff
    )

    begin {
        if (-not(Get-Command quser -ErrorAction SilentlyContinue)) {
            throw 'Could not find quser.exe. Make sure it is installed on the system.'
        }

        $quserResult = & quser /server:$Server 2>&1
        $qObject = $quserResult -replace '\s{2,}',',' | ConvertFrom-Csv
    }

    process {

        if($PSBoundParameters.ContainsKey('Logoff')) {
            $task = $qObject | Out-GridView -OutputMode Multiple -Title "Select users:"
            foreach( $user in $task) {
                logoff $user.id /server:$Server 2>&1
            }
        }
        else {
            return $qObject
        }
    }
}

# Example usage:
# Get-Quser | Format-Table -AutoSize
# Get-Quser -Logoff
