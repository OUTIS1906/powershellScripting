Function Enable-GodMode{
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]$Path = [Environment]::GetFolderPath('Desktop')
    )

    try {
        $GodMode = @{
            Path     = $Path
            Name     = "GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
            ItemType = 'Directory'
        }
        New-Item @GodMode -Force -EA Stop | Out-Null
        "Enabled god mode - see the new icon - $Path"

    }
    catch {
        "Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    }
}Enable-GodMode
