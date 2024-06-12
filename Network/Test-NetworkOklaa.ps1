Function Test-NetworkOklaa {
    
    Write-Progress -Activity "Gathering information" -PercentComplete -1

    $downloadUrl     = "https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-win64.zip"
    $destiantionZip  = [io.path]::Combine($env:TEMP,'ookla-speedtest-1.2.0-win64.zip')
    $destiantionPath = [io.path]::Combine($env:TEMP,'ookla-speedtest-1.2.0-win64')
    
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($downloadUrl,$destiantionZip)
    $webClient.Dispose()

    Add-Type -Assembly System.IO.Compression.Filesystem

    if ([io.directory]::Exists($destiantionPath)) {
        [io.directory]::Delete($destiantionPath,$True)
    }
    [IO.Compression.Zipfile]::ExtractToDirectory($destiantionZip, $destiantionPath)

    $filePath = [IO.Directory]::EnumerateFiles($destiantionPath,'speedtest.exe')

    if($null -ne $filePath) {

        # $Result = & $filePath --accept-gdpr --accept-license --format=json | ConvertFrom-Json

        $processInfo = @{
            FileName               = $filePath
            Arguments              = "--accept-gdpr --accept-license --format=json-pretty --progress=no"
            RedirectStandardOutput = $true
            RedirectStandardError  = $true
            UseShellExecute        = $false
            CreateNoWindow         = $true
        }
        
        $process = [System.Diagnostics.Process]::Start($processInfo)
        
        $stdOutput = $process.StandardOutput.ReadToEnd()
        $stdError  = $process.StandardError.ReadToEnd()
        
        $process.WaitForExit()
        
        if ($process.ExitCode -eq 0) {
            $Result = $stdOutput | ConvertFrom-Json -ErrorAction SilentlyContinue

            Write-Progress -Activity "Gathering information" -Completed
            
            return ([PSCustomObject]@{
                DownloadSpeed = [math]::Round($Result.download.bandwidth / 1000000 * 8, 2)
                UploadSpeed   = [math]::Round($Result.upload.bandwidth / 1000000 * 8, 2)
                PacketLoss    = [math]::Round($Result.packetLoss)
                ISP           = $Result.isp
                ExternalIP    = $Result.interface.externalIp
                InternalIP    = $Result.interface.internalIp
                UsedServer    = $Result.server.host
                URL           = $Result.result.url
                Jitter        = [math]::Round($Result.ping.jitter)
                Latency       = [math]::Round($Result.ping.latency)    
            })
        }
        else {
            Write-Warning "Error:`n$stdError"
        } 
    }
} 

# Example usage:
# Test-NetworkOklaa
