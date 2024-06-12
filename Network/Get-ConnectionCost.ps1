function Get-ConnectionCost {

    [Windows.Networking.Connectivity.NetworkInformation, Windows, ContentType = WindowsRuntime] > $null
    [Windows.Networking.Connectivity.NetworkInformation]::GetInternetConnectionProfile().GetConnectionCost()
} 

# Example usage:
# Get-ConnectionCost

function Set-ConnectionCost {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet("Fixed","Unrestricted")]
        [string]$CostMode
    )

    [Windows.Networking.Connectivity.NetworkInformation, Windows, ContentType = WindowsRuntime] > $null
    $connectionName = [Windows.Networking.Connectivity.NetworkInformation]::GetInternetConnectionProfile().GetNetworkNames()

    if( $null -ne $connectionName) {
        & netsh wlan set profileparameter name="$connectionName" cost="$CostMode" 2>&1
    }
    else {
        Write-Warning "Network profile not found."
    }
}

# Example usage:
# Set-ConnectionCost -CostMode Unrestricted
