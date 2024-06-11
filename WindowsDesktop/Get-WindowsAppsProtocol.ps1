function Get-WindowsAppsProtocol {

    $Results = [Collections.ArrayList]::new()

    foreach ($key in Get-ChildItem -Path "registry::HKEY_CLASSES_ROOT") {
        $Path   = [IO.Path]::Combine($key.PSPath, 'shell\open\command')
        $hasUrl = $key.Property -contains 'URL Protocol'

        if ($hasUrl -and (Test-Path -Path $Path)) {
            $commandKey   = Get-Item -Path $Path
            $keyName      = $key.Name.Substring($key.Name.IndexOf('\') + 1)
            $commandValue = $commandKey.GetValue('')

            $ResultObject = [PSCustomObject]@{
                Name    = $keyName
                Command = $commandValue
            }

            $Results.Add($ResultObject) > $null
        }
    }

    return $Results | Sort-Object -Property Name
}

# Example usage:
# Get-WindowsAppsProtocol
# Get-WindowsAppsProtocol | Out-GridView
