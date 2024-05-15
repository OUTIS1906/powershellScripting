Function Enable-ClassicPhotoViewer {
    
    if(-not(Test-Path -Path "C:\Program Files\Windows Photo Viewer\PhotoViewer.dll" -PathType Leaf)) {
        Write-Warning "Photo Viewer .dll files is not available."
        return
    }
    else {
        $extensions = @(
            ".bmp", ".cr2", ".dib", ".gif", ".ico", ".jfif", ".jpe", ".jpeg", ".jpg", ".jxr", ".png", ".tif", ".tiff", ".wdp"
        )
    
        foreach ($ext in $extensions) {
            $extKey = "HKCU:\SOFTWARE\Classes\$ext"
            $openWithProgidsKey = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$ext\OpenWithProgids"
            
            if (-not (Test-Path -Path $extKey -PathType Container)) {
                New-Item -Path $extKey -Force > $null
            }
            
            if (-not (Test-Path -Path $openWithProgidsKey -PathType Container)) {
                New-Item -Path $openWithProgidsKey -Force > $null
            }
    
            New-ItemProperty -Path $extKey -Name "(Default)" -Value "PhotoViewer.FileAssoc.Tiff" -Force > $null
            New-ItemProperty -Path $openWithProgidsKey -Name "PhotoViewer.FileAssoc.Tiff" -Value 0x0 -Force > $null
        }
    }
}

# Example usage:
# Enable-ClassicPhotoViewer
