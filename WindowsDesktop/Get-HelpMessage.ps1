function Get-HelpMessage {
    [CmdletBinding()]
    [Alias('HelpMsg')]
    param (
        [Parameter(HelpMessage = "Provide error code -Id 1412 | 0x123")]
        [int]$Id
    )
    try {
        [ComponentModel.Win32Exception] $id
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

# Example usage:
# Get-HelpMessage 1412
# Get-HelpMessage 0x123
