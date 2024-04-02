function Get-GPUInfo {
        [CmdletBinding()]
        param (
            [Parameter(HelpMessage = "Provide remote computer name (default is current machine)")]
            [string[]]$ComputerName = $env:computername
        )

        if($PSEdition -ne 'Desktop') { Write-Warning "Powershell Code doesn't support WMI-Object class."; return;; }

        enum EnumAvailability {
                Other                       = 1
                Unknown                     = 2
                Running_FullPower           = 3
                Warning                     = 4
                InTest                      = 5
                NotApplicable               = 6
                PowerOff                    = 7
                OffLine                     = 8
                OffDuty                     = 9
                Degraded                    = 10
                NotInstalled                = 11
                InstallError                = 12
                PowerSave_Unknown           = 13
                PowerSave_LowPowerMode      = 14
                PowerSave_Standby           = 15
                PowerCycle                  = 16
                PowerSave_Warning           = 17
                Paused                      = 18
                NotReady                    = 19
                NotConfigured               = 20
                Quiesced                    = 21
        }

        enum EnumVideoArchitecture {
                Other                 = 1
                Unknown               = 2
                CGA                   = 3
                EGA                   = 4
                VGA                   = 5
                SVGA                  = 6
                MDA                   = 7
                HGC                   = 8
                MCGA                  = 9
                _8514A                = 10
                XGA                   = 11
                Linear_Frame_Buffer   = 12
                PC_98                 = 160
        }

        enum EnumVideoMemoryType {
                Other                    = 1
                Unknown                  = 2
                VRAM                     = 3
                DRAM                     = 4
                SRAM                     = 5
                WRAM                     = 6
                EDO_RAM                  = 7
                Burst_Synchronous_DRAM   = 8
                Pipelined_Burst_SRAM     = 9
                CDRAM                    = 10
                _3DRAM                   = 11
                SDRAM                    = 12
                SGRAM                    = 13
        }
            
        foreach($Computer in $ComputerName) {

                try {
                        $gpuDetails = Get-WmiObject Win32_VideoController -ErrorAction Stop -ComputerName $computername

                        $psObject = @()
                        foreach($gpu in $gpuDetails){
                                $psObject += [PSCustomObject]@{
                                        Computer      = $computer
                                        Availability  = [EnumAvailability]$gpu.Availability
                                        Model         = $gpu.Caption
                                        RAM           = [math]::Round(($gpu.AdapterRAM / 1GB),2)
                                        MemoryType    = [EnumVideoMemoryType]$gpu.VideoMemoryType
                                        Width         = $gpu.CurrentHorizontalResolution
                                        Height        = $gpu.CurrentVerticalResolution
                                        BitsPerPixel  = $gpu.CurrentBitsPerPixel
                                        RefreshRate   = $gpu.CurrentRefreshRate
                                        DeviceID      = $gpu.DeviceID
                                        DriverVersion = $gpu.DriverVersion
                                        InfFilename   = $gpu.InfFilename 
                                        Description   = $gpu.VideoModeDescription
                                        Architecture = [EnumVideoArchitecture]$gpu.VideoArchitecture
                                        Family        = $gpu.VideoProcessor
                                        Status        = $gpu.Status
                                    }
                        }

                        $psObject
                        
                    }
                    catch {
                        Write-Warning "Failed to retrieve information from $computer"
                        # "Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0].Exception.Message)"
                    }
        }
}

# Example usage:
# Get-GPUInfo | Format-List -GroupBy Family
# Get-GPUInfo -ComputerName REMOTE-PC1, REMOTE-PC2 | Format-List -GroupBy Computer
