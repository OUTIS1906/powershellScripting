function Set-DisplaySwitch {
    [CmdletBinding()]
    param (
        [Parameter(
            HelpMessage="Specifies the display configuration to apply. Valid values are 'Clone', 'Extend', 'External', or 'Internal'. Default/none value brings DisplaySwitch.exe menu."
        )]
        [ValidateSet('Clone','Extend','External','Internal')]
        [string]$Switch
    )

    $displaySwitchPath = 'C:\Windows\System32\DisplaySwitch.exe'

    $switchParam = @{
        'Internal' = '/internal'
        'External' = '/external'
        'Clone'    = '/clone'
        'Extend'   = '/extend'
    }[$Switch]

    if (-not (Test-Path -Path $displaySwitchPath -PathType Leaf)) {
        Write-Error "DisplaySwitch.exe not found."
        return
    }
    else {
        & $displaySwitchPath $switchParam
    }

}

# Example usage:
# Set-DisplaySwitch
# Set-DisplaySwitch -Switch Extend
