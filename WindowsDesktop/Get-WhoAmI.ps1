Function Get-WhoAmI {
    [CmdletBinding()]
    [Alias('who')]
    [OutputType('PSCustomObject')]
    Param()

    $CIM = Get-CimInstance Win32_OperatingSystem -Property Caption, Version, OSArchitecture
    $OS = "$($CIM.Caption) [$($CIM.OSArchitecture)]"

    $current   = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$current
    $elevated  = $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

    $SID = $current.User.Value
    $userKey = (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\*\$SID\Usernames\*")

    $UPN,$Type =  if ($null -ne $userKey) {
        $userKey.PSChildName, $userKey.GetSubKeyNames()
    }



    [PSCustomObject]@{
        UserName          = $current.Name
        UserPrincipalName = $UPN
        SID               = $SID  
        AccountType       = $Type
        Elevated          = $elevated
        ComputerName      = $env:COMPUTERNAME
        OperatingSystem   = $OS
        OSVersion         = $CIM.Version
        PSVersion         = $PSVersionTable.PSVersion.ToString()
        Edition           = $PSVersionTable.PSEdition
        PSHost            = $host.Name
        WSMan             = $PSVersionTable.WSManStackVersion.ToString()
        ExecutionPolicy   = (Get-ExecutionPolicy)
        Culture           = [System.Globalization.CultureInfo]::CurrentCulture.NativeName
    }
}

# Example usage:
# Get-WhoAmI
