function Get-WindowsCPUArchitecutre {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Provide remote computer name (default is current machine)")]
        [string[]]$ComputerName = $env:computername
    )

    if($PSEdition -ne 'Desktop') { Write-Warning "Powershell Code doesn't support WMI-Object class."; return;; }

    foreach($computer in $ComputerName)
    {
        try{
            $cpuInfo = Get-WmiObject -Class Win32_Processor -ErrorAction Stop -ComputerName $computer 
            $osInfo  = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction Stop -ComputerName $computer
    
            [pscustomobject]@{
                Computer        = $computer
                CpuName         = $cpuInfo.Name
                NumberOfCores   = $cpuInfo.NumberOfCores
                CpuArchitecture = @{
                    0  = "x86"
                    5  = "ARM"
                    6  = "ia64"
                    9  = "x64"
                    12 = "ARM64"
                }[[int]$cpuInfo.Architecture]
                WindowsArchitecture = $osInfo.OSArchitecture
            }
        }
        catch {
            Write-Warning "Failed to retrieve information from $computer"
        }
    }
} 

# Example usage:
# Get-WindowsCPUArchitecutre
# Get-WindowsCPUArchitecutre -ComputerName REMOTE-PC1, REMOTE-PC2 | Format-List -GroupBy Computer
