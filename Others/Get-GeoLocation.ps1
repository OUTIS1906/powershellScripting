Function Get-GeoLocation {
    Write-Host "Getting Geo-Location..."

    $Uri = "https://ipinfo.io/json"
    $Result = Invoke-RestMethod -Uri $Uri

    $GeoLocation = [PSCustomObject]@{
        Latitude    = $Result.loc.Split(',')[0]
        Longitude   = $Result.loc.Split(',')[1]
        City        = $Result.city
        Country     = $Result.country
        PostalCode  = $Result.postal
    }

    <# Opennnig GeoLocation in GoogleMaps
    $GoogleMapsUrl = "https://www.google.com/maps?q=$($GeoLocation.Latitude),$($GeoLocation.Longitude)"
    Start-Process $GoogleMapsUrl
    #>

    return $GeoLocation

}Get-GeoLocation
