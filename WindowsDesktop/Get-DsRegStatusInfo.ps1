function Get-DsRegStatusInfo {

	[System.Threading.Thread]::CurrentThread.CurrentCulture   = 'en-US'
    [System.Threading.Thread]::CurrentThread.CurrentUICulture = 'en-US'

	$outputText = & dsregcmd.exe /status

	$psObject = [PSCustomObject]@{}

	foreach ($line in $outputText) {
		
		$pattern = "^\s*([a-zA-Z\s-]+)\s*:\s*(.*?)\s*$"
		$matches = [regex]::Matches($line, $pattern)

		if ($matches.Success) {

			$key   = $matches.Groups[1].Value.Trim()
			$value = $matches.Groups[2].Value.Trim()

			$psObject | Add-Member -MemberType NoteProperty -Name $key -Value $value
		}
	}
	return $psObject
}

# Example usage:
# Get-DsRegStatusInfo
