Function Repair-AppxPackage {
    [CmdletBinding(DefaultParameterSetName='Package')]
    param (
        [Parameter(ParameterSetName='Package', ValueFromPipeline = $true, Position = 0)]
        [pscustomobject] $Package,

        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='Name')]
        [string] $Name,

        [Parameter(ParameterSetName='GridView')]
        [switch] $OutGridView
    )

    begin {
        if (-not (Get-Module APPX)) { 
            Write-Warning "Importing Appx Module."
            Import-Module APPX -UseWindowsPowerShell -WarningAction Ignore
        }
    }

    process {

        switch ($PSCmdlet.ParameterSetName) {
            'Package' {
                if ($Package -is [System.Management.Automation.PSObject] -and ($Package | Get-Member -MemberType Property | Where-Object { $_.Name -eq 'InstallLocation' })) {
                    $AppxObject = $Package
                }
                else {
                    Write-Warning "Wrong -Package parameter input."; return;;
                }
            }
            'Name' {
                if ($PSBoundParameters.ContainsKey('Name')) {
                    $AppxObject = Get-AppxPackage -Name $Name
                }
            }

            'GridView' {
                if ($PSBoundParameters.ContainsKey('OutGridView')) {
                    $AppxObject = Get-AppxPackage | Out-GridView -Title "Select app for repairing:" -OutputMode Multiple
                }
            }
        }

        if ($null -ne $AppxObject) {
            foreach ($item in $AppxObject) {
    
                Write-Warning "`rRepairing $($item.PackageFullName) package..."
                $appxManifest = [IO.Path]::Combine($item.InstallLocation,"appxmanifest.xml")
                
                if (-not (Test-Path -Path $appxManifest -PathType Leaf)) {
                    Write-Host "`rAppxManifest.xml doesn't exist." -ForegroundColor Red
                }
                else {
                    try {
                        Write-Host "Repairing...`r" -NoNewline -ForegroundColor Yellow
                            Add-AppxPackage -Register $appxManifest -DisableDevelopmentMode -ForceTargetApplicationShutdown
                        Write-Host "`rRepaired." -ForegroundColor Green
                    }
                    catch {
                        #throw "Failed to repair $($item.PackageFullName): $_"
                        Write-Host "`rFailed to repair $($item.PackageFullName): $_" -ForegroundColor Red
                    }
                }
            }
        }
        else {
            Write-Host "`rCould not find a matching package for the specified name." -ForegroundColor Yellow
        }
    }
}

# Example usage:
# Get-AppxPackage *paint* | Repair-AppxPackage
# Repair-AppxPackage -Name *paint*
# Repair-AppxPackage -OutGridView
