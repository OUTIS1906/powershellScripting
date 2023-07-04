#Requires -RunAsAdministrator:$false

Function Enable-PhotoViewer{

    $PhotoVwrDLL = 'C:\Program Files\Windows Photo Viewer\PhotoViewer.dll'
    if(Test-Path -Path $PhotoVwrDLL -PathType Leaf){
    
        $extensions = @(
            ".bmp",
            ".cr2",
            ".dib",
            ".gif",
            ".ico",
            ".jfif",
            ".jpe",
            ".jpeg",
            ".jpg",
            ".jxr",
            ".png",
            ".tif",
            ".tiff",
            ".wdp"
        )
        
        $progId = "PhotoViewer.FileAssoc.Tiff"
        $registryPath = "HKCU:\SOFTWARE\Classes"
        
        foreach ($extension in $extensions) {
            $extKeyPath = Join-Path -Path $registryPath -ChildPath $extension
            if (-not (Test-Path $extKeyPath)) {
                New-Item -Path $extKeyPath -ItemType RegistryKey -Force -Value $progId  | Out-Null
            }
            Set-Item -Path $extKeyPath -Value $progId -Force
        }
        
        $explorerPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts"
        
        foreach ($extension in $extensions) {
            $extKeyPath = Join-Path -Path $explorerPath -ChildPath "$extension\OpenWithProgids"
            if (-not (Test-Path $extKeyPath)) {
                New-Item -Path $extKeyPath -Force | Out-Null
            }
            New-ItemProperty -Path $extKeyPath -Name $progId -Value ([byte[]]@(0)) -PropertyType ([Microsoft.Win32.RegistryValueKind]::None) -Force | Out-Null
        }
        
    }
    else{ Write-Host "$PhotoVwrDLL doesn't exist" } 
    
}Enable-PhotoViewer
