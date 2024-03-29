function Generate-QRCode {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = "Provide URL or text to convert to QR code."
        )]
        [string] $Text,
        
        [Parameter(
            HelpMessage = "Image size (e.g. 500x500)."
        )]
        [string] $ImageSize = "500x500",

        [Parameter()]
        [ValidateSet("jpg", "png", "jpeg", "gif", "bmp", "tiff")]
        [string]$FileFormat = "jpg",
        
        [Parameter()]
        [string] $SavePath = ([io.path]::GetTempFileName() -replace '\.tmp$', ".$FileFormat"),

        [Parameter()]
        [switch] $Display
        
    )

        $ECC             = "M" # Error correction level (can be L, M, Q, H)
        $QuietZone       = 1
        $ForegroundColor = "000000"
        $BackgroundColor = "ffffff"
        # $FileFormat      = "jpg"

        $QRCodeUrl = "http://api.qrserver.com/v1/create-qr-code/?data=$Text&ecc=$ECC&size=$ImageSize&qzone=$QuietZone&color=$ForegroundColor&bgcolor=$BackgroundColor&format=$FileFormat"

    try {
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile($QRCodeUrl, $SavePath)
        $WebClient.Dispose()
    
        Write-Host "Saved new QR code image file to: $SavePath"

        if($PSBoundParameters.ContainsKey('Display')) { &$SavePath }
    }
    catch {
        Write-Warning "Failed to generate QR-Code."
    }
}

# Example usage:
# Generate-QRCode -Text google.pl -ImageSize 300x300 -FileFormat jpg
