Function Get-MainIPAddress {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$IPAddress = ""
    )

    $result = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$IPAddress"

    $outputObject = [PSCustomObject]@{}
    if ($result.status -eq 'fail') {
        $outputObject | Add-Member -NotePropertyName 'Status' -NotePropertyValue $result.status
        $outputObject | Add-Member -NotePropertyName 'Message' -NotePropertyValue $result.message
        $outputObject | Add-Member -NotePropertyName 'Query' -NotePropertyValue $result.query
    } else {
        $outputObject | Add-Member -NotePropertyName 'Status' -NotePropertyValue 'success'
        $outputObject | Add-Member -NotePropertyName 'Country' -NotePropertyValue $result.country
        $outputObject | Add-Member -NotePropertyName 'CountryCode' -NotePropertyValue $result.countryCode
        $outputObject | Add-Member -NotePropertyName 'Region' -NotePropertyValue $result.region
        $outputObject | Add-Member -NotePropertyName 'RegionName' -NotePropertyValue $result.regionName
        $outputObject | Add-Member -NotePropertyName 'City' -NotePropertyValue $result.city
        $outputObject | Add-Member -NotePropertyName 'ZIP' -NotePropertyValue $result.zip
        $outputObject | Add-Member -NotePropertyName 'Latitude' -NotePropertyValue $result.lat
        $outputObject | Add-Member -NotePropertyName 'Longitude' -NotePropertyValue $result.lon
        $outputObject | Add-Member -NotePropertyName 'Timezone' -NotePropertyValue $result.timezone
        $outputObject | Add-Member -NotePropertyName 'ISP' -NotePropertyValue $result.isp
        $outputObject | Add-Member -NotePropertyName 'Organization' -NotePropertyValue $result.org
        $outputObject | Add-Member -NotePropertyName 'AutonomousSystem' -NotePropertyValue $result.as
        $outputObject | Add-Member -NotePropertyName 'Query' -NotePropertyValue $result.query
    }

    $outputObject

}Get-MainIPAddress
