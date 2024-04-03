Function Get-MotherboardInfo {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Provide remote computer name (default is current machine)")]
        [string[]]$ComputerName = $env:computername
    )

    if($PSEdition -ne 'Desktop') { Write-Warning "Powershell Code doesn't support WMI-Object class."; return;; }

    foreach($Computer in $ComputerName) {

        try{
            $mbInfo    = Get-WmiObject -Class Win32_BaseBoard -ErrorAction Stop -ComputerName $computer 

            [pscustomobject]@{
                Computer        = $computer
                Type            = $mbInfo.Caption
                Manufacturer    = $mbInfo.Manufacturer
                Product         = $mbInfo.Product
                SerialNumber    = $mbInfo.SerialNumber
                Version         = $mbInfo.Version
                Removable       = $mbInfo.Removable
                Replaceable     = $mbInfo.Replaceable

            }

        }
        catch {
            Write-Warning "Failed to retrieve information from $computer"
            # "Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0].Exception.Message)"
        }
    }
} 

# Example usage:
# Get-MotherboardInfo
# Get-MotherboardInfo -ComputerName REMOTE-PC1, REMOTE-PC2 | Format-List -GroupBy Computer
