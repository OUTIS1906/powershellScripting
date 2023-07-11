Function Get-ShotUrl{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
        [string]$Url
    )
    try {
        $response = Invoke-RestMethod -Uri "http://tinyurl.com/api-create.php?url=$Url"
        $shortUrl = $response.Trim()
        Write-Host "Short URL: $shortUrl"
    } catch {
        Write-Host "Failed to generate short URL." -ForegroundColor Red
    }
}Get-ShotUrl
