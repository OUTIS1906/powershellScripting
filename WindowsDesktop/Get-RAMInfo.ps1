Function Get-RAMInfo {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Provide remote computer name (default is current machine)")]
        [string[]]$ComputerName = $env:computername
    )

   if($PSEdition -ne 'Desktop') { Write-Warning "Powershell Code doesn't support WMI-Object class."; return;; }
   
    $typeMapping = @{
        0  = "Unknown"
        1  = "Other"
        2  = "DRAM"
        3  = "Synchronous DRAM"
        4  = "Cache DRAM"
        5  = "EDO RAM"
        6  = "EDRAM"
        7  = "VRAM"
        8  = "SRAM"
        9  = "RAM"
        10 = "ROM"
        11 = "Flash"
        12 = "EEPROM"
        13 = "FEPROM"
        14 = "EPROM"
        15 = "CDRAM"
        16 = "3DRAM"
        17 = "SDRAM"
        18 = "SGRAM"
        19 = "RDRAM"
        20 = "DDR RAM"
        21 = "DDR2 RAM"
        22 = "DDR2 FB-DIMM"
        24 = "DDR3 RAM"
        26 = "DDR4 RAM"
        25 = "FBD2 RAM"
        27 = "DDR5 RAM"
        28 = "DDR6 RAM"
        29 = "DDR7 RAM"

        #custome
        34 = "DDR5 RAM Dell"
    }

    $factorMapping = @{
        0  = "Unknown"
        1  = "Other"
        2  = "SIP"
        3  = "DIP"
        4  = "ZIP"
        5  = "SOJ"
        6  = "Proprietary"
        7  = "SIMM"
        8  = "DIMM"
        9  = "TSOP"
        10 = "PGA"
        11 = "RIMM"
        12 = "SODIMM"
        13 = "SRIMM"
        14 = "SMD"
        15 = "SSMP"
        16 = "QFP"
        17 = "TQFP"
        18 = "SOIC"
        19 = "LCC"
        20 = "PLCC"
        21 = "BGA"
        22 = "FPBGA"
        23 = "LGA"
        24 = "FB-DIMM"
    }
    

    function Bytes2String {
        param([int64]$Bytes)
    
        $units = "bytes", "KB", "MB", "GB", "TB", "PB", "EB"
        $index = 0
    
        while ($Bytes -ge 1024 -and $index -lt $units.Length - 1) {
            $Bytes /= 1024
            $index++
        }
        return "$Bytes $($units[$index])"
    }

    foreach ($computer in $ComputerName) {
        try{
            $Banks = Get-WmiObject -Class Win32_PhysicalMemory -ErrorAction Stop -ComputerName $computer 
    
            $Results = foreach ($Bank in $Banks) {
                [PSCustomObject]@{
                    Computer     = $computer
                    Capacity     = "{0} GB" -f ($Bank.Capacity / 1GB)                                #Bytes2String $Bank.Capacity
                    Type         = $typeMapping[[int]$Bank.SMBIOSMemoryType]
                    Factor       = $factorMapping[[int]$Bank.FormFactor]
                    Speed        = $Bank.Speed
                    Voltage      = [float]($Bank.ConfiguredVoltage / 1000.0)
                    Manufacturer = $Bank.Manufacturer
                    Location     = "{0}/{1}" -f $Bank.BankLabel, $Bank.DeviceLocator   #"$($Bank.BankLabel)/$($Bank.DeviceLocator)"
                    Serial       = $Bank.SerialNumber
                    PartNumber   = $Bank.PartNumber
                }     
            }
            $Results
        }
        catch {
            Write-Warning "Failed to retrieve information from $computer"
        }  
    }
}

# Example usage:
# Get-RAMInfo
# Get-RAMInfo -ComputerName REMOTE-PC1, REMOTE-PC2 | Format-List -GroupBy ComputerGet-RAMInfo | Format-List -GroupBy Computer
