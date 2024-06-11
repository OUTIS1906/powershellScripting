function Get-AppxProtocol {
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Position  = 0,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]$Name,
        # AllUsers requires elevated permission
        [switch]$AllUsers 
    )

    $AppXProtocolArray = New-Object System.Collections.ArrayList

    foreach ($AppName in $Name) {

        Write-Verbose "Getting AppX package information for $AppName"
        $Apps = Get-AppxPackage -Name $AppName -AllUsers:$AllUsers.isPresent

        foreach ($App in $Apps) {

            Write-Verbose "Getting AppX package manifest for $($App.Name)"
            [xml]$AppXManifest = $App | Get-AppxPackageManifest

            $Protocol = ($AppXManifest.Package.Applications.Application.Extensions.Extension |
                            Where-Object -FilterScript {$_.Category -eq 'windows.protocol'} |
                                Select-Object -Property ChildNodes).ChildNodes.Name

            $AppXProtocolProperties = [PSCustomObject]@{
                Name        = $App.Name
                Protocol    = $Protocol
                Path        = $App.InstallLocation
                Executable  = $AppXManifest.Package.Applications.Application.Executable
            }

            $AppXProtocolArray.Add($AppXProtocolProperties) | Out-Null
        }
    }

    # Return the ArrayList of objects
    return $AppXProtocolArray | Sort-Object -Property Name
}

# Example usage:
# Get-AppxProtocol -Name *notes*
# Get-AppxProtocol * | Out-GridView
