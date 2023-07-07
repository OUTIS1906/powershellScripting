Function Save-ScreenShot{
    param(       
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]$Path = [Environment]::GetFolderPath('MyPictures')
    )

    function TakeScreenshot {([string]$FilePath)

        Add-Type -Assembly System.Windows.Forms            

        $ScreenBounds       = [Windows.Forms.SystemInformation]::VirtualScreen
        $ScreenshotObject   = New-Object Drawing.Bitmap $ScreenBounds.Width, $ScreenBounds.Height

        $DrawingGraphics    = [Drawing.Graphics]::FromImage($ScreenshotObject)
        $DrawingGraphics.CopyFromScreen( $ScreenBounds.Location, [Drawing.Point]::Empty, $ScreenBounds.Size)
        $DrawingGraphics.Dispose()

        $ScreenshotObject.Save($FilePath)
        $ScreenshotObject.Dispose()
    }
    
    try {
        $Time = (Get-Date)
        $Filename = "$($Time.Year)-$($Time.Month)-$($Time.Day)_T-$($Time.Hour)-$($Time.Minute)-$($Time.Second).png"
        $FilePath = (Join-Path -Path $Path -ChildPath $Filename)

        TakeScreenshot($FilePath)
        "Screenshot saved to $FilePath"
    
    } catch {
        "Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    }
}Save-ScreenShot
