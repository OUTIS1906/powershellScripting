function Set-AutodeskUpdates {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet(0,2)]
        [uint]$Value

        # 0 - Enable
        # 2 - Disable
    )

    
    $userSid = (New-Object System.Security.Principal.NTAccount((Get-CimInstance Win32_ComputerSystem).Username)).Translate([System.Security.Principal.SecurityIdentifier]).Value
    $regPath = "registry::HKEY_USERS\$userSid\SOFTWARE\Autodesk\ODIS"

    if(-not(Test-Path -Path $regPath -PathType Container)){ 
        New-Item -Path $regPath -ItemType Directory -Force > $null
    } 

    New-ItemProperty -Path $regPath -Name DisableManualUpdateInstall -PropertyType DWORD -Value $Value -Force > $null
}

# Example usage:
# Set-AutodeskUpdates -Value 0


function Enable-AutodeskUpdates {

    $userSid = (New-Object System.Security.Principal.NTAccount((Get-CimInstance Win32_ComputerSystem).Username)).Translate([System.Security.Principal.SecurityIdentifier]).Value
    $regPath = "registry::HKEY_USERS\$userSid\SOFTWARE\Autodesk\ODIS"

    if(-not(Test-Path -Path $regPath -PathType Container)){ 
        New-Item -Path $regPath -ItemType Directory -Force > $null
    } 

    New-ItemProperty -Path $regPath -Name DisableManualUpdateInstall -PropertyType DWORD -Value 0 -Force > $null
}

# Example usage:
# Enable-AutodeskUpdates


function Disable-AutodeskUpdates {

    $userSid = (New-Object System.Security.Principal.NTAccount((Get-CimInstance Win32_ComputerSystem).Username)).Translate([System.Security.Principal.SecurityIdentifier]).Value
    $regPath = "registry::HKEY_USERS\$userSid\SOFTWARE\Autodesk\ODIS"

    if(-not(Test-Path -Path $regPath -PathType Container)){ 
        New-Item -Path $regPath -ItemType Directory -Force > $null
    } 

    New-ItemProperty -Path $regPath -Name DisableManualUpdateInstall -PropertyType DWORD -Value 2 -Force > $null
}

# Example usage:
# Disable-AutodeskUpdates


function Toogle-AutodeskUpdates {
    $userSid = (New-Object System.Security.Principal.NTAccount((Get-CimInstance Win32_ComputerSystem).Username)).Translate([System.Security.Principal.SecurityIdentifier]).Value
    $regPath = "registry::HKEY_USERS\$userSid\SOFTWARE\Autodesk\ODIS"

    if(-not(Test-Path -Path $regPath -PathType Container)){ 
        New-Item -Path $regPath -ItemType Directory -Force > $null
    } 

    $hastable = @{
        $true  = 0
        $false = 2 
    }

    [bool]$modify = (Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue).DisableManualUpdateInstall
    New-ItemProperty -Path $regPath -Name DisableManualUpdateInstall -PropertyType DWORD -Value $hastable[[bool]$modify] -Force > $null
}

# Example usage:
# Toogle-AutodeskUpdates
