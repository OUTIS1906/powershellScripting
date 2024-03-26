Function Repair-AppxPackage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name
    )

    if (-not (Get-Command Get-AppxPackage -ErrorAction SilentlyContinue)) { 
        Write-Warning "Importing Appx Module."
        Import-Module APPX -UseWindowsPowerShell -WarningAction Ignore
    }

    try {
        $AppxPackages = Get-AppxPackage -Name $Name
    }
    catch {
        throw "Failed to retrieve AppxPackage: $_"
    }

    if ($null -ne $AppxPackages) {
        foreach ($AppxPackage in $AppxPackages) {
            Write-Warning "`rRepairing $($AppxPackage.PackageFullName) package..."

            $appxManifest = Join-Path -Path $AppxPackage.InstallLocation -ChildPath "appxmanifest.xml"

            if (-not (Test-Path -Path $appxManifest -PathType Leaf)) {
                Write-Host "`rAppxManifest.xml doesn't exist" -NoNewline -ForegroundColor Red
            }
            else {
                try {
                    Write-Host "Repairing..." -NoNewline -ForegroundColor Yellow
                    Add-AppxPackage -Register $appxManifest -DisableDevelopmentMode -ForceTargetApplicationShutdown
                    Write-Host -NoNewline "`r"
                    Write-Host "`rRepaired." -NoNewline -ForegroundColor Green

                }
                catch {
                    throw "Failed to repair $($AppxPackage.PackageFullName): $_"
                }
            }
        }
    }
}
