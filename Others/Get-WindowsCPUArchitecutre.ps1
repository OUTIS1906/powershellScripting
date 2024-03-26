Function Get-WindowsCPUArchitecutre{
    # Get CPU Information
    $cpuInfo = Get-CimInstance Win32_Processor

    # Get Windows Architecture
    $osInfo = Get-CimInstance Win32_OperatingSystem

    # Create and display the custom object
    [PSCustomObject]@{
        "CPU Name"          = $cpuInfo.Name
        "Number of Cores"   = $cpuInfo.NumberOfCores
        "CPU Architecture" = @{
            0 = "x86"
            5 = "ARM"
            6 = "ia64"
            9 = "x64"
            12 = "ARM64"
        }[[int]$cpuInfo.Architecture]
        "Windows Architecture" = (Get-CimInstance Win32_OperatingSystem).OSArchitecture
    } | Format-List
}
