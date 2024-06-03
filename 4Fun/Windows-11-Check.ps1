#Requires -RunAsAdministrator
# ----------------------------------------------------------------

Function Test-CPU-Requirements {
    Start-Sleep -Milliseconds 250
 
     $cpuRequirements = @{
         clockSpeed   = [UInt16] 1000
         coresNumber  = [UInt16] 2
         architecture = [UInt16] 64
     }
 
     $installedCPU = Get-CimInstance -Class Win32_Processor
 
     $cpuPossessed = @{
         clockSpeed    = [UInt16] $installedCPU.MaxClockSpeed
         coresNumber   = [UInt16] $installedCPU.NumberOfCores 
         architecture  = [UInt16] $installedCPU.AddressWidth
     }
     
     foreach ($key in $cpuRequirements.Keys) {
         if ($cpuPossessed[$key] -lt $cpuRequirements[$key]) {
             return "Failed"
         }
     }
 
     return "Passed"
 }

 # ----------------------------------------------------------------
 
 Function Test-RAM-Requirements {
     Start-Sleep -Milliseconds 250
 
     $ramRequirements = @{
         ramAmount = [uint16] 4
     }
 
     $memoryModules = Get-CimInstance -ClassName Win32_PhysicalMemory
 
     $ramPossesed = @{
         ramAmount = ($memoryModules | Measure-Object -Property Capacity -Sum).Sum / 1GB
     }
 
     foreach ($key in $ramRequirements.Keys) {
         if ($ramPossesed[$key] -lt $ramRequirements[$key]) {
             return "Failed"
         }
     }
 
     return "Passed"
 }
 
 # ----------------------------------------------------------------
 
 
 Function Test-TPM-Requirements {
     Start-Sleep -Milliseconds 250
 
     try {
         $tpmInfo = Get-CimInstance -Namespace "Root\CIMv2\Security\MicrosoftTpm" -Class Win32_Tpm -ErrorAction Stop
 
         # Check if TPM is present
         if ($null -ne $tpmInfo) {
     
             $majorVersion = $tpmInfo.SpecVersion.Split(",")[0] -as [int]
             if ($majorVersion -ge 2) {
                 return "Passed"
             }
         }
     
         return "Failed"
     }
     catch [Microsoft.Management.Infrastructure.CimException] {
 
         Write-Output "Admin rights missing"
         return "Failed"
     }
     catch {
         return "Failed"
     }
 }
 
 # ----------------------------------------------------------------
 
 Function Test-Display-Requirements {
     Start-Sleep -Milliseconds 250
 
     Add-Type -AssemblyName System.Windows.Forms
 
     $displayRequrements = @{
         width     = [UInt16] 1280
         height    = [UInt16] 720
         colorDeep = [UInt16] 24
     }
     
     $displayPossesed = @{
         width     = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
         height    = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height
         colorDeep = [System.Windows.Forms.Screen]::PrimaryScreen.BitsPerPixel
     }
 
     foreach ($key in $displayRequrements.Keys) {
         if ($displayPossesed[$key] -lt $displayRequrements[$key]) {
             return "Failed"
         }
     }
 
     return "Passed"
 }
 
 #overwriten:Test-Display-Requirements
 Function Test-Display-Requirements {
     Start-Sleep -Milliseconds 250
 
     $displayRequirements = @{
         width      = [UInt16] 1280
         height     = [UInt16] 720
         colorDepth = [UInt16] 24  # Assuming 8 bits per color channel (24 bits per pixel)
     }
 
     $primaryMonitor = Get-CimInstance -ClassName Win32_VideoController
 
     $displayPossessed = @{
         width      = $primaryMonitor.CurrentHorizontalResolution
         height     = $primaryMonitor.CurrentVerticalResolution
         colorDepth = $primaryMonitor.CurrentBitsPerPixel
     }
 
     foreach ($key in $displayRequirements.Keys) {
         if ($displayPossessed[$key] -lt $displayRequirements[$key]) {
             return "Failed"
         }
     }
 
     return "Passed"
 }
 
 # ----------------------------------------------------------------
 
 Function Test-SecureBoot-Requirements {
    Start-Sleep -Milliseconds 250
 
     try {
         $isSecureBootEnabled = Confirm-SecureBootUEFI
         return "Passed"
     }
     catch [System.PlatformNotSupportedException] {
         Write-Output "Non-UEFI environment"
         return "Failed"
     }
     catch [System.UnauthorizedAccessException] {
         Write-Output "Admin rights missing"
         return "Failed"
     }
     catch {
         return "Failed"
     }
 }
  
 # ----------------------------------------------------------------
 
 Function Test-Storage-Requirements {
    Start-Sleep -Milliseconds 250
 
     $storageRequirements = @{
         freeStorage = [UInt16] 64
     }
 
     $logicalDisks = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
 
     $storagePossesed = @{
         freeStorage = ($logicalDisks | Measure-Object -Property FreeSpace -Sum).Sum / 1GB
     }
 
     foreach ($key in $storageRequirements.Keys) {
         if ($storagePossesed[$key] -lt $storageRequirements[$key]) {
             return "Failed"
         }
     }
 
     return "Passed"
 }
  
 # ----------------------------------------------------------------
 
 $validationObject = New-Object PSObject -Property @{
     CPU         = 'N/A'
     RAM         = 'N/A'
     TPM         = 'N/A'
     Display     = 'N/A'
     SecureBoot  = 'N/A'
     Storage     = 'N/A'
 }
 
 $tests = @(
     @{Name = 'CPU';        Function = 'Test-CPU-Requirements'       },
     @{Name = 'RAM';        Function = 'Test-RAM-Requirements'       },
     @{Name = 'TPM';        Function = 'Test-TPM-Requirements'       },
     @{Name = 'Display';    Function = 'Test-Display-Requirements'   },
     @{Name = 'SecureBoot'; Function = 'Test-SecureBoot-Requirements'},
     @{Name = 'Storage';    Function = 'Test-Storage-Requirements'   }
 )
 
 for ($i = 0; $i -lt $tests.Count; $i++) {
 
     $progressParams = @{
         Activity        = "Windows 11 - Components Validation"
         Status          = ("Checking: {0}" -f $tests[$i].Name)
         PercentComplete = (($i / $tests.Count) * 100)
     }
 
     Write-Progress @progressParams
 
     $validationObject | Add-Member -MemberType NoteProperty -Name $tests[$i].Name -Value (& $tests[$i].Function) -Force
 }
 
 Write-Progress -Activity "Completed." -Completed
 
 return $validationObject
