function Get-DsRegStatusInfo {
    begin {

        <#
        $processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processStartInfo.FileName               = 'dsregcmd.exe'
        $processStartInfo.Arguments              = '/status'
        $processStartInfo.UseShellExecute        = $false
        $processStartInfo.RedirectStandardOutput = $true
        $processStartInfo.CreateNoWindow         = $true

        $process    = [System.Diagnostics.Process]::Start($processStartInfo)
        $outputText = $process.StandardOutput.ReadToEnd()
        $process.Close()
        #>
        
        # Run dsregcmd.exe and capture the output
        $outputText = & dsregcmd.exe /status
    }

    process {
        $psObject = [PSCustomObject]@{}

        foreach ($line in $outputText) {
            
            $pattern = "^\s*([a-zA-Z\s-]+)\s*:\s*(.*?)\s*$"
            $matches = [regex]::Matches($line, $pattern)

            if ($matches.Success) {

                $key   = $matches.Groups[1].Value.Trim()
                $value = $matches.Groups[2].Value.Trim()

                $psObject | Add-Member -MemberType NoteProperty -Name $key -Value $value
            }
        }
    }

    end {
        return $psObject 
    }
}

# Example usage:
# Get-DsRegStatusInfo
