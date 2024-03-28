function Generate-Password {
    param (
        [int] $passwordLength = 16,
        [int] $amountOfNonAlphanumeric = 3
    )

    if ($PSEdition -eq "Desktop") {
        Add-Type -AssemblyName System.Web
        return [System.Web.Security.Membership]::GeneratePassword($passwordLength, $amountOfNonAlphanumeric)
    }
    else { Write-Warning "Powershell Core is not supported" }
}Generate-Password

# Example usage:
# Generate-Password -passwordLength 12 -amountOfNonAlphanumeric 12


function Generate-Password {
    param (
        [int] $passwordLength = 16,
        [switch] $IncludeNonAlphanumeric
    )

    $charSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    
    if ($IncludeNonAlphanumeric) {
        $charSet += '!@#$%^&*()-=_+'
    }

    $bytes = New-Object byte[] $passwordLength
    $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
    $rng.GetBytes($bytes)

    $result = for ($i = 0; $i -lt $passwordLength; $i++) {
        $charSet[$bytes[$i] % $charSet.Length]
    }

    return  -join  $result
}Generate-Password

# Example usage:
# Generate-Password -passwordLength 12 -IncludeNonAlphanumeric



function Generate-Password {
    param (
        [int] $passwordLength = 16
    )

    $Characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+[]{}|;:,.<>?"


    for ($i = 0; $i -lt $passwordLength; $i++) {
        $Password += $Characters[(Get-Random -Maximum $Characters.Length)]
    }

    return $Password
}Generate-Password

# Example usage:
# Generate-Password -passwordLength 12
