Function Get-WindowsProductCode {
    # Set registry key path
    $path = "registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\"

    # Get registry key value
    $digitalID = (Get-ItemProperty -Path $path -Name "DigitalProductId").DigitalProductId

    # Function to convert binary to chars
    function ConvertToKey($key) {
        $keyOffset = 52
        $isWin8 = $null
        $maps = "BCDFGHJKMPQRTVWXY2346789"
        $output = ""

        # Check if OS is Windows 8
        if (($key[66] -shr 6) -band 1) { $isWin8 = $true }
        $key[66] = ($key[66] -band 0xf7) -bor (($isWin8 -as [int]) * 4)

        # Convert binary to chars
        $i = 24
        do {
            $current = 0
            $j = 14
            do {
                $current = $current * 256
                $current = $key[$j + $keyOffset] + $current
                $key[$j + $keyOffset] = [math]::Floor($current / 24)
                $current = $current % 24
                $j--
            } while ($j -ge 0)
            $i--
            $output = $maps[$current] + $output
            $last   = $current
        } while ($i -ge 0)

        # Insert "N" in product key for Windows 8
        if ($isWin8) {
            $keyPart1 = $output.Substring(1, $last)
            $insert   = "N"
            $output   = $output.Replace($keyPart1, "$keyPart1$insert", 2, 1)
            if ($last -eq 0) { $output = $insert + $output }
        }

        # Format product key
        return $output.Substring(0, 5) + "-" + $output.Substring(5, 5) + "-" + $output.Substring(10, 5) + "-" + $output.Substring(15, 5) + "-" + $output.Substring(20, 5)
    }

    $WinCode = (ConvertToKey $digitalID)
    Write-Output "Windows Product Code: $WinCode"
}

# Example usage:
# Get-WindowsProductCode
