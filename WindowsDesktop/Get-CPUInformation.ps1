Function Get-CPUInformation {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Provide remote computer name (default is current machine)")]
        [string[]]$ComputerName = $env:computername
    )

    if($PSEdition -ne 'Desktop') { Write-Warning "Powershell Code doesn't support WMI-Object class."; return;; }

    foreach($Computer in $ComputerName) {

        try{
            $cpuInfo    = Get-WmiObject -Class Win32_Processor -ErrorAction Stop -ComputerName $computer 
            $osInfo     = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction Stop -ComputerName $computer
            $termalInfo = Get-WmiObject -Query "SELECT * FROM Win32_PerfFormattedData_Counters_ThermalZoneInformation" -Namespace "root/CIMV2" -ErrorAction  Stop -ComputerName $computer 

            $temp = foreach($item in $termalInfo.HighPrecisionTemperature) { 
                [math]::Round($item / 100.0, 1)
            }

            [pscustomobject]@{
                Computer        = $computer
                CpuName         = $cpuInfo.Name
                DeviceID        = $cpuInfo.DeviceID
                NumberOfCores   = $cpuInfo.NumberOfCores
                LogicalCores    = [System.Environment]::ProcessorCount
                CpuArchitecture = @{
                    0  = "x86"
                    5  = "ARM"
                    6  = "ia64"
                    9  = "x64"
                    12 = "ARM64"
                }[[int]$cpuInfo.Architecture]
                Speed               = $cpuInfo.MaxClockSpeed
                Socket              = $cpuInfo.SocketDesignation
                WindowsArchitecture = $osInfo.OSArchitecture
                Temperature         = $temp -join ' | '
            }

        }
        catch {
            Write-Warning "Failed to retrieve information from $computer"
        }
    }
} 

# Example usage:
# Get-CPUInformation
# Get-CPUInformation -ComputerName REMOTE-PC1, REMOTE-PC2 | Format-List -GroupBy Computer
