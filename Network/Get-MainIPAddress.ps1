Function Get-MainIPAddress {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$IPAddress = ""
    )

    try {
        $result = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$IPAddress" -ErrorAction Stop

        if ($result.status -eq 'fail') {
            $outputObject = [PSCustomObject]@{
                Status           = $result.status
                Message          = $result.message
                Query            = $result.query
            }
        }
        else {
            $outputObject = [PSCustomObject]@{
                Status           = $result.status
                Country          = $result.country
                CountryCode      = $result.countryCode
                Region           = $result.region
                RegionName       = $result.regionName
                City             = $result.city
                ZIP              = $result.zip
                Latitude         = $result.lat
                Longitude        = $result.lon
                Timezone         = $result.timezone
                ISP              = $result.isp
                Organization     = $result.org
                AutonomousSystem = $result.as
                Query            = $result.query
            }
        }
        return $outputObject
    }       
    catch {
        Write-Warning "Failed to invoke web-request."
    }
}

# Example usage:
# Get-MainIPAddress
