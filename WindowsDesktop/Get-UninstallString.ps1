
function Get-UninstallString {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            HelpMessage       = "Provide application name (wildcards are accepted for pattern matching)"
            
            )]
        [string] $ApplicationName,
        [switch] $Detailed
    )

    $UninstallKeys = @(
        "registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\",
        "registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\"
    )
    
    if (([System.Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')) {
        $UninstallKeys += "registry::HKEY_USERS\S*\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
    }
    else{
        $UninstallKeys += "registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
    }
    
    $Properties = @('DisplayName','Publisher','UninstallString','DisplayVersion','InstallDate','InstallLocation')

    if($PSBoundParameters.ContainsKey('Detailed')) {
        $Properties = "*"
    }

    $UninstallKeys = $UninstallKeys | Get-ChildItem -Force -Recurse | Get-ItemProperty | 
                Where-Object { $_.DisplayName -like $ApplicationName } |
                            Select-Object -Property $Properties

    return $UninstallKeys
}

# Example Usage:
# Get-UninstallString -ApplicationName *teams* | Format-Table -AutoSize
# Get-UninstallString -ApplicationName *365* -Detailed | Format-List -GroupBy Publisher
