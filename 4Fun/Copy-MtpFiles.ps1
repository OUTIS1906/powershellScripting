# updated function Copy-MtpFiles on the bottom of script
Function Copy-MtpFiles {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$DeviceName,
        
        [Parameter(Mandatory)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$DestinationPath,
        
        [Parameter()]
        [string]$Filter = "*"
    )
    function Copy-Files {
        param (
            [System.__ComObject]$SourceFolder,
            [System.__ComObject]$DestinationFolder,
            [string]$Filter
        )
        
        foreach ($item in $SourceFolder.Items()) {
            if ($item.IsFolder) {
                Copy-Files -SourceFolder $item.GetFolder -DestinationFolder $DestinationFolder -Filter $Filter
            }
            elseif ($item.Name -like $Filter) {
                $DestinationFolder.CopyHere($item)
                Write-Host -NoNewline "Copied: "
                Write-Host $item.Name -ForegroundColor Yellow     
            }
        }
    }

    $Shell = New-Object -ComObject Shell.Application
    $PhoneObject = $Shell.Namespace(17).Self.GetFolder.Items() | Where-Object { $_.Name -match $DeviceName }

    if ($null -ne $PhoneObject) {
        $DestinationFolder = $Shell.Namespace($DestinationPath).Self.GetFolder
        Copy-Files -SourceFolder $PhoneObject.GetFolder -DestinationFolder $DestinationFolder -Filter $Filter
    }
    else {
        Write-Warning "Device '$DeviceName' not found."
    }
}

Function Show-MtpDevices {
    $Shell = New-Object -ComObject Shell.Application
    $PhoneObject = $Shell.Namespace(17).Self.GetFolder.Items()

    # Initialize a generic list to store MTP devices
    $MtpDevices = [System.Collections.Generic.List[PSObject]]::new()

    foreach ($device in $PhoneObject) {
        if ($device.Path -match "\\?\\usb#") {
            $MtpDevices.Add($device)
        }
    }

    if ($MtpDevices.Count -eq 0) {
        Write-Warning "No MTP devices found."
        return $null
    }

    return $MtpDevices
}


Function Copy-MtpFiles {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory        = $true,
            ParameterSetName = 'ByName'
        )]
        [string]$DeviceName,

        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            ParameterSetName  = 'ByObject'
        )]
        [PSCustomObject]$Device,

        [Parameter()]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$DestinationPath,

        [Parameter()]
        [string]$Filter = "*"
    )
    
    function Copy-Files {
        param (
            [System.__ComObject]$SourceFolder,
            [System.__ComObject]$DestinationFolder,
            [string]$Filter
        )
        
        foreach ($item in $SourceFolder.Items()) {
            if ($item.IsFolder) {
                Copy-Files -SourceFolder $item.GetFolder -DestinationFolder $DestinationFolder -Filter $Filter
            }
            elseif ($item.Name -like $Filter) {
                $DestinationFolder.CopyHere($item)
                Write-Host -NoNewline "Copied: "
                Write-Host $item.Name -ForegroundColor Yellow
            }
        }
    }

    $Shell = New-Object -ComObject Shell.Application
    $DestinationFolder = $Shell.Namespace($DestinationPath).Self.GetFolder

    if ($PSCmdlet.ParameterSetName -eq 'ByName') {
        $PhoneObject = $Shell.Namespace(17).Self.GetFolder.Items() | Where-Object { $_.Name -match $DeviceName }   

        if ($null -ne $PhoneObject) {
            Copy-Files -SourceFolder $PhoneObject.GetFolder -DestinationFolder $DestinationFolder -Filter $Filter
        }
        else {
            Write-Warning "Device '$DeviceName' not found."
        }
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'ByObject') {
        
        if ($null -ne $Device) {
            Copy-Files -SourceFolder $Device.GetFolder -DestinationFolder $DestinationFolder -Filter $Filter
        else {
            Write-Warning "Device not found."
        }
    }
}

# Example usage:
# Using DeviceName:
# Show-MtpDevices 
# Copy-MtpFiles -DeviceName "apple" -DestinationPath "C:\Temp\Powershell\" -Filter "*.jpg"

# Using Device object:
# $mtpDevices = Show-MtpDevices
# $Copy-MtpFiles -Device $mtpDevices -DestinationPath "C:\Temp\Powershell\" -Filter "*.jpg"
# Show-MtpDevices | Copy-MtpFiles -DestinationPath "C:\Temp\Powershell\" -Filter *.jpg
