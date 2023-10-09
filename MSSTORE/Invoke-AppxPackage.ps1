Function Invoke-AppxPackage{

    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet("pl-PL","en-US")]
        [string]$Language = "en-US",
        [string]$Url = (((Invoke-WebRequest -Uri "https://raw.githubusercontent.com/OUTIS1906/powershellScripting/main/MSSTORE/appBase.json" -UseBasicParsing).Content | ConvertFrom-Json ) |  
        Out-GridView -OutputMode Single -Title "Apps List").Url
    )

    [System.Console]::SetWindowPosition(0,[System.Console]::CursorTop)

    Write-Warning "Microsoft Store Apps Downloader"

    $Script:TempPath = "C:\Temp\Powershell\StoreDownloads"
    if(-not(Test-Path $TempPath -PathType Container)){ [void] (New-Item -Path $TempPath -ItemType Directory) }

    <#
        $AppBase = (((Invoke-WebRequest -Uri "https://raw.githubusercontent.com/OUTIS1906/powershellScripting/main/MSSTORE/appBase.json" -UseBasicParsing).Content | ConvertFrom-Json ) |  
        Out-GridView -OutputMode Single -Title "Apps List").Url
    #>

    $body = @{
        type = 'url'
        url  = $Url
        ring = 'RP'
        lang = $Language
    }

    $ApiParam = @{
        Method          = "POST"
        Body            = $body
        ContentType     = 'application/x-www-form-urlencoded'
        Uri             = "https://store.rg-adguard.net/api/GetFiles"
        UseBasicParsing = $true
        ErrorAction     = "Stop"
    }

    try{ $WebResponse = Invoke-WebRequest @ApiParam } catch{Throw " Error occurred: API Web-Request not issue." }
    
        
    # Find links that match the pattern for .appx, .appxbundle, .msix, or .msixbundle (only extensions)
    $Applications = @()

    $Applications = $WebResponse.Links | Where-Object { $_.OuterHTML -match '/([^/]+)\.(appx|appxbundle|msix|msixbundle)\b' } | ForEach-Object {
        $match = [regex]::Match($_.OuterHTML, 'rel="noreferrer">(.*?)<\/a>')
        [PSCustomObject]@{
            FileName     = $match.Groups[1].Value
            DownloadLink = $_.href  
        }
    }

    if($Applications.count -gt 0){

        $WebClient = New-Object System.Net.WebClient

        foreach($download in $Applications | Where-Object { $_.FileName -match 'X64|neutral'} | Out-GridView -Title "Download Manager" -OutputMode Multiple){

            $DownloadParams = @{
                Source = $download.DownloadLink
                Destination = Join-Path $TempPath -ChildPath $download.FileName
                DisplayName = "Downloading of $($download.FileName)"
                Description = $download.DownloadLink
                Priority    = "High"
            }
            
            "Target:{0}" -f $Download.Filename
            #Write-Host "Downloading: $($DownloadParams.DisplayName)"
            "Downloading..."
            #Start-BitsTransfer @DownloadParams
            $WebClient.DownloadFile($DownloadParams.Source,$DownloadParams.Destination)

            [System.Console]::SetWindowPosition(0,[System.Console]::CursorTop)
            "Installing..."
            #Write-Host "Installing:  $($DownloadParams.DisplayName)"
            
            try{
                Add-AppxPackage -Path $DownloadParams.Destination -ForceApplicationShutdown -ErrorAction Stop
                Write-Host "Completed." -ForegroundColor Green
            }
            catch{
                Write-Host ($Error[0].Exception.InnerException) -ForegroundColor Red
            }
        }
    }
    else { Write-Host "WARNING: Cannot match result from API resources" -ForegroundColor Yellow }
    
}
