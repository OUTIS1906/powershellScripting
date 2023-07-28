Function Install-DellTrackpadFix{

    $isRefferingMachine = (gcim Win32_ComputerSystem).Model -match "Latitude 7430"

    $TempPath = "C:\Temp\Powershell"
    if (-not (Test-Path $TempPath)) { New-Item $TempPath -Force -ItemType Directory | Out-Null }

    try{[System.Console]::SetWindowPosition(0,[System.Console]::CursorTop)}catch{}

    if($isRefferingMachine){
        Write-Warning "Deploying Trackpad Fix for Dell Latitude 7430..."

        $DownloadParams = @{
            Source      = "https://dl.dell.com/FOLDER09148898M/1/Dell-Touchpad-Firmware-Update-Utility_RGNY7_WIN64_1160.4160.259.0_A00.EXE"
            Destination = Join-Path -Path $TempPath -ChildPath "Dell-Touchpad-Firmware-Update-Utility_RGNY7_WIN64_1160.4160.259.0_A00.EXE"
            DisplayName = "Trackpad Fix for Dell Latitude 7430"
            Description = "Downloading..."
        }

        try{
            $WebClient = New-Object System.Net.WebClient
            $WebClient.DownloadFile($DownloadParams.Source,$DownloadParams.Destination)
            $WebClient.Dispose()

            $ExitCode = (Start-Process -FilePath $DownloadParams.Destination -ArgumentList ("/factoryinstall /passthrough /s") -PassThru -Wait -ErrorAction Stop).ExitCode
            #Start-Process -FilePath $DownloadParams.Destination -ArgumentList "/factoryinstall /passthrough" -Wait -ErrorAction Stop

            if (($ExitCode -eq 0) -or ($ExitCode -eq 2)) {
                Write-Host "Completed!" -ForegroundColor Green 
                if( (Read-Host -Prompt "Changes will not take effect until reboot. Press `"y`" to do so now, any other key to exit...") -eq 'y'){ shutdown -r -t 30 -c "In about 30 seconds Windows will reboot. "}
            }
            else{
                Write-Host "Something went wrong!"
            }
        }
        catch{
            Start-Process "https://dl.dell.com/FOLDER09148898M/1/Dell-Touchpad-Firmware-Update-Utility_RGNY7_WIN64_1160.4160.259.0_A00.EXE" | Out-Null
            "Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
            Throw "ISSUE: Update failed - continue manually"
        }
    }
    else{
        Write-Warning "Current  target: $((gcim Win32_ComputerSystem).Model)"
        Write-Warning "Required target: Latitude 7430"
    }

}Install-DellTrackpadFix
