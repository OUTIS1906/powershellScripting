function Set-WindowsLoginDisclaimer {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory   = $true,
            HelpMessage = "Enter the caption for the Windows login disclaimer."
        )]
        [string]$Caption,
        [Parameter(
            Mandatory   = $true,
            HelpMessage = "Enter the text for the Windows login disclaimer."
        )]
        [string]$Text,
        [switch]$Force
    )

    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

    if(-not($PSBoundParameters.ContainsKey('Force'))) {
        "Caption: {0}`nText: {1}" -f $Caption, $Text
        $confirmation = Read-Host "Do you want to change the Windows login disclaimer? (Y/N)"

        if ($confirmation -ne 'Y') {
            Write-Output "Windows login disclaimer has been cancelled."
            return
        }
    }

    Set-ItemProperty -Path $registryPath -Name "legalnoticecaption" -Value $Caption -Type String -Force > $null
    Set-ItemProperty -Path $registryPath -Name "legalnoticetext"    -Value $Text    -Type String -Force    > $null

    Write-Output "Windows login disclaimer has been successfully updated."
}

# Example usage:
# Set-WindowsLoginDisclaimer -Caption "Attention!" -Text "All rights reserved." -Force
