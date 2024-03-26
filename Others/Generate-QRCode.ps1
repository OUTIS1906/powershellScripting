Function Generate-QRCode {
    [CmdletBinding()]
    param (
        [string]$Text = $(Read-Host "Enter text or URL"),
        [string]$ImageSize = $(Read-Host "Enter image size (e.g. 500x500)"),
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]$Path = [Environment]::GetFolderPath('MyPictures')
    )

    try {
        $ECC = "M" # can be L, M, Q, H
        $QuietZone = 1
        $ForegroundColor = "000000"
        $BackgroundColor = "ffffff"
        $FileFormat = "jpg"
        
        $FileName = "QR_code_1.jpg"
        $NewFile = Join-Path $Path $FileName

        if (Test-Path $NewFile -PathType Leaf) {
            $counter = 1
            while (Test-Path $NewFile -PathType Leaf) {
                $counter++
                $FileName = "QR_code_$counter.jpg"
                $NewFile = Join-Path $Path $FileName
            }
        }
    
        $WebClient = New-Object System.Net.WebClient
        $QRCodeUrl = "http://api.qrserver.com/v1/create-qr-code/?data=$Text&ecc=$ECC&size=$ImageSize&qzone=$QuietZone&color=$ForegroundColor&bgcolor=$BackgroundColor&format=$FileFormat"
        $WebClient.DownloadFile($QRCodeUrl, $NewFile)
    
        "Saved new QR code image file to: $NewFile"
    
    } catch {
        "Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    }
}
