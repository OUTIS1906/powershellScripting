Function Get-CPUInformation {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Provide remote computer name (default is current machine)")]
        [string[]]$ComputerName = $env:computername
    )

    if($PSEdition -ne 'Desktop') { Write-Warning "Powershell Code doesn't support WMI-Object class."; return;; }

    Write-Progress -Activity "Gathering information" -PercentComplete -1

    foreach($Computer in $ComputerName) {

        try{
            $cpuInfo    = Get-WmiObject -Class Win32_Processor -ErrorAction Stop -ComputerName $computer 
            $osInfo     = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction Stop -ComputerName $computer
            $termalInfo = Get-WmiObject -Query "SELECT * FROM Win32_PerfFormattedData_Counters_ThermalZoneInformation" -Namespace "root/CIMV2" -ErrorAction  Stop -ComputerName $computer 

            $usageCpu   = (Get-Counter -ComputerName $ComputerName -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 2 -MaxSamples 5).CounterSamples |
                            Measure-Object -Property CookedValue -Average

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
                Usage               = [math]::Round($usageCpu.Average,2)
                Socket              = $cpuInfo.SocketDesignation
                WindowsArchitecture = $osInfo.OSArchitecture
                Temperature         = $temp -join ' | '
            }

            Write-Progress -Activity "Gathering information" -Completed

        }
        catch {
            Write-Warning "Failed to retrieve information from $computer"
            # "Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0].Exception.Message)"
        }
    }
} 

# Example usage:
# Get-CPUInformation
# Get-CPUInformation -ComputerName REMOTE-PC1, REMOTE-PC2 | Format-List -GroupBy Computer
