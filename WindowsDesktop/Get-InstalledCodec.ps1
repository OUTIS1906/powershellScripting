function Get-InstalledCodec {

    $registryPath = "registry::HKEY_CLASSES_ROOT\WOW6432Node\CLSID\{083863F1-70DE-11D0-BD40-00A0C911CE86}\Instance\"

    $psObject = Get-ChildItem $registryPath | ForEach-Object {
        $props = Get-ItemProperty -Path $_.PSPath
        [PSCustomObject]@{
            FriendlyName = $props.FriendlyName
            Enabled      = !($props.CLSID.StartsWith(":"))
            CLSID        = $props.CLSID
            FileName     = (Get-ItemProperty -Path "registry::HKEY_CLASSES_ROOT\CLSID\$($props.CLSID.TrimStart(':'))\InprocServer32" -EA SilentlyContinue).'(Default)'           
        }
    }
    $psObject

    # disabled codec's CLSID starts from :
    # :{1B544C20-FD0B-11CE-8C63-00AA0044B51E}
}

# Example Usgae:
# Get-InstalledCodec
