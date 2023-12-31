function Uninstall-WinUpdate {

    Write-Warning "Windows Updates..."
    $updateList = Get-HotFix | Select-Object -Property  HotFixID, InstalledOn, InstalledBy, Description,PSComputerName | Sort-Object -Property InstalledOn  | Out-GridView -Title "Installed Updates" -OutputMode Multiple

    foreach ($update in $updateList) {

        try{[System.Console]::SetWindowPosition(0,[System.Console]::CursorTop)}catch{}
        #Write-Host "Uninstalling:"; $update
        Write-Output "Uninstalling:" $update | Format-Table
        $KB = $update.HotFixID.split("KB")[-1]

        if (-not([string]::IsNullOrWhiteSpace($KB))) {
            try {
                Start-Process wusa.exe -ArgumentList "/uninstall /kb:$KB" -Wait -ErrorAction Stop
            }
            catch [System.InvalidOperationException] {
                Write-Host "Issue occurred during removing"
            }
        }
        else{
            Write-Host "Null or empty value in Update[KB] field"
        }
    }
}Uninstall-WinUpdate
