function Get-WindowsCPUArchitecutre {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Provide remote computer name (default is current machine)")]
        [string]$ComputerName = $env:computername
    )

    if($PSEdition -ne 'Desktop') { Write-Warning "Powershell Code doesn't support WMI-Object class."; return;; }

    try{
        $cpuInfo = Get-WmiObject -Class Win32_Processor -ComputerName $ComputerName
        $osInfo  = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName

        return [pscustomobject]@{
            "CPU Name"             = $cpuInfo.Name
            "Number of Cores"      = $cpuInfo.NumberOfCores
            "CPU Architecture"     = @{
                0  = "x86"
                5  = "ARM"
                6  = "ia64"
                9  = "x64"
                12 = "ARM64"
            }[[int]$cpuInfo.Architecture]
            "Windows Architecture" = $osInfo.OSArchitecture
        }
    }
    catch {
        Write-Warning "Failed to retrieve information from $computername"
    }
} 

# Example usage:
# Get-WindowsCPUArchitecutre
# Get-WindowsCPUArchitecutre -ComputerName REMOTE-PC
