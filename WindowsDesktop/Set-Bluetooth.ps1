Function Set-Bluetooth {

    [CmdletBinding()] 
    Param( 
        [Parameter()]
        [ValidateSet('On', 'Off')]
        [string]$BluetoothStatus
    )

    if ($PSEdition -ne "Desktop") {
        Write-Warning "Powershell Core is not supported"; return;;
    }
    
    if ((Get-Service bthserv).Status -eq 'Stopped'){ Start-Service bthserv }

    Add-Type -AssemblyName System.Runtime.WindowsRuntime
    $asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]

    Function Await($WinRtTask, $ResultType){
        $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
        $netTask = $asTask.Invoke($null, @($WinRtTask))
        $netTask.Wait(-1)  | Out-Null
        $netTask.Result
    }

    [Windows.Devices.Radios.Radio,Windows.System.Devices,ContentType=WindowsRuntime] | Out-Null
    [Windows.Devices.Radios.RadioAccessStatus,Windows.System.Devices,ContentType=WindowsRuntime] | Out-Null
    Await ([Windows.Devices.Radios.Radio]::RequestAccessAsync()) ([Windows.Devices.Radios.RadioAccessStatus])  | Out-Null

    $radios = Await ([Windows.Devices.Radios.Radio]::GetRadiosAsync()) ([System.Collections.Generic.IReadOnlyList[Windows.Devices.Radios.Radio]])
    $bluetooth = $radios | Where-Object { $_.Kind -eq 'Bluetooth' }

    [Windows.Devices.Radios.RadioState,Windows.System.Devices,ContentType=WindowsRuntime] | Out-Null

    if (!$BluetoothStatus){
        if ($bluetooth.state -eq 'On'){
            $BluetoothStatus = 'Off'
        }
        else{
            $BluetoothStatus = 'On'
        }
    }
    Await ($bluetooth.SetStateAsync($BluetoothStatus)) ([Windows.Devices.Radios.RadioAccessStatus]) # | Out-Null
}

# Example usage:
# Set-Bluetooth -BluetoothStatus Off
