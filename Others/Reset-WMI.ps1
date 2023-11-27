Function Reset-WMI{

    try{[System.Console]::SetWindowPosition(0,[System.Console]::CursorTop)}catch{}
    Write-Warning "-----------WMI FIX-----------"

    $Script:ErrorActionPreference = 'Stop'

    #-----------------------------------------------------------------------------
    Write-Warning "0) Stopping services"
    try{
        $winmgmt = Get-Service -Name winmgmt
        $winmgmt | Stop-Service -Force
        $winmgmt | Set-Service -StartupType Disabled

        Write-Host '>Completed' -ForegroundColor 'Green'
    }

    catch{ Write-Host '>Failed' -ForegroundColor 'Red' }
    #-----------------------------------------------------------------------------
    
    Write-Warning "1) Removing back_up %System32%\wbem\Repository[.old | .bak]"
    $backUp = @(
        "C:\Windows\System32\wbem\Repository_bak",
        "C:\Windows\System32\wbem\Repository.bak"
        "C:\Windows\System32\wbem\Repository_old",
        "C:\Windows\System32\wbem\Repository.old"
    )

    try{
        foreach($path in $backUp){
            if(Test-Path -Path $path -PathType Container){ Remove-item -Path $path -Force -Recurse }
        }
        Write-Host '>Completed' -ForegroundColor 'Green'
    }
    catch{ Write-Host '>Failed' -ForegroundColor 'Red' }
    #-----------------------------------------------------------------------------

    Write-Warning "2) Creating back_up %system32%\wbem\Repository.bak"
    try{
        Rename-Item -Path "C:\Windows\System32\wbem\Repository" -NewName "Repository.bak" -Force
        Write-Host '>Completed' -ForegroundColor 'Green'
    }
    catch{ Write-Host '>Failed' -ForegroundColor 'Red' }
    #-----------------------------------------------------------------------------

    Write-Warning "3) Registering .dll files"
    try{
        Get-ChildItem -Path "C:\Windows\System32\wbem" -Filter "*.dll" | ForEach-Object { regsvr32.exe /s $_.FullName }
        #Get-ChildItem -Path "C:\Windows\System32\wbem" -Filter "*.dll" | ForEach-Object { Start-Process regsvr32.exe -ArgumentList "/s $($_.FullName)" -NoNewWindow -Wait }
        
        Write-Host '>Completed' -ForegroundColor 'Green'
    }
    catch{ Write-Host '>Failed' -ForegroundColor 'Red' }
    #-----------------------------------------------------------------------------

    Write-Warning "4) Registering .exe files"
    try{
        Get-ChildItem -Path "C:\Windows\System32\wbem" -Filter "*.exe" | Where-Object { $_.Name -notin @("wbemcntl.exe", "wbemtest.exe", "mofcomp.exe") } | ForEach-Object { 
            Start-Process -FilePath $_.FullName -ArgumentList "/Regserver" -WindowStyle Hidden -Wait 
        }
        Write-Host '>Completed' -ForegroundColor 'Green'
    }
    catch{ Write-Host '>Failed' -ForegroundColor 'Red' }
    #-----------------------------------------------------------------------------

    Write-Warning "5) Registering .mof | .mfl files"
    try{
        Get-ChildItem -Path "C:\Windows\System32\wbem"  | Where-Object { $_.Extension -in ".mof",".mfl" }  | ForEach-Object { Mofcomp.exe $_.FullName 2>&1 | Out-Null }
        #Get-ChildItem -Path "C:\Windows\System32\wbem"  | Where-Object { $_.Extension -in ".mof",".mfl" }  | ForEach-Object { Start-Process Mofcomp.exe -ArgumentList $_.FullName -NoNewWindow -Wait | Out-Null }
        
        Write-Host '>Completed' -ForegroundColor 'Green'
    }
    catch{ Write-Host '>Failed' -ForegroundColor 'Red' }
    #-----------------------------------------------------------------------------

    Write-Warning "6) Starting services"
    try{
        $winmgmt | Set-Service -StartupType Automatic
        $winmgmt | Start-Service
        Write-Host '>Completed' -ForegroundColor 'Green'
    }
    catch{ Write-Host '>Failed' -ForegroundColor 'Red' }
    #-----------------------------------------------------------------------------

}Reset-WMI
