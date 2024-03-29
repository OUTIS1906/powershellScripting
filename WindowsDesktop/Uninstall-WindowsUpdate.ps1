function Uninstall-WindowsUpdate {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch] $Quiet
    )

    $updateList = Get-HotFix | Select-Object -Property  HotFixID, InstalledOn, InstalledBy, Description,PSComputerName | 
            Sort-Object -Property InstalledOn -Descending | 
                    Out-GridView -Title "Installed Updates" -OutputMode Multiple

    if($null -eq $updateList){
        Write-Warning "No updates available."; return;;
    }

    foreach ($update in $updateList) {

        Write-Output "Uninstalling:" 
        Write-Output -InputObject $update

        $updateNumber = $update.HotFixID.Trim("KB")

        if (-not([string]::IsNullOrWhiteSpace($updateNumber))) {

            $uninstallParams = @(
                "/uninstall",
                "/kb:$updateNumber",
                "/norestart",
                "/log:c:\Temp\uninstall-kb-$updateNumber.log"
            )
            if($PSBoundParameters.ContainsKey('Quiet')) { $uninstallParams += '/quiet'}

            try {
                $result = Start-Process wusa.exe -ArgumentList $uninstallParams -Wait -ErrorAction Stop -PassThru
                Write-Host "Completed. ExitCode: $($result.ExitCode)" -ForegroundColor Green
            }
            catch [System.InvalidOperationException] {
                Write-Host "An issue occurred during removing." -ForegroundColor Red
            }
        }
        else{
            Write-Host "Update number is null/empty." -ForegroundColor Yellow
        }
    }
}

# Example usage:
# Uninstall-WindowsUpdate -Quiet
