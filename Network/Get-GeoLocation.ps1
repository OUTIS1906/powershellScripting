Function Get-GeoLocation {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]$FullDetailed
    )

    try {
        $Uri    = "https://ipinfo.io/json"
        $Result = Invoke-RestMethod -Uri $Uri
    
        $GeoLocation = [PSCustomObject]@{
            IPAdress    = $Result.ip
            Latitude    = $Result.loc.Split(',')[0]
            Longitude   = $Result.loc.Split(',')[1]
            City        = $Result.city
            Region      = $Result.region
            PostalCode  = $Result.postal
            Country     = $Result.country
        }

        if($PSBoundParameters.ContainsKey('FullDetailed')) {
            return $Result
        }
        else {
            return $GeoLocation
        }
    }
    catch {
        Write-Warning "Failed to invoke web-request."
    }

    <# Opennnig GeoLocation in GoogleMaps

    $GoogleMapsUrl = "https://www.google.com/maps?q=$($GeoLocation.Latitude),$($GeoLocation.Longitude)"
    Start-Process $GoogleMapsUrl
    #>

} 

# Example usage:
# Get-GeoLocation -FullDetailed
