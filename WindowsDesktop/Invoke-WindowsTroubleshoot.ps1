Function Invoke-WindowsTroubleshoot {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet(
            "AeroDiagnostic",
            "NetworkDiagnosticsDA",
            "DeviceDiagnostic",
            "HomeGroupDiagnostic",
            "NetworkDiagnosticsInbound",
            "NetworkDiagnosticsWeb",
            "IEBrowseWebDiagnostic",
            "IESecurityDiagnostic",
            "NetworkDiagnosticsNetworkAdapter",
            "PerformanceDiagnostic",
            "AudioPlaybackDiagnostic",
            "PowerDiagnostic",
            "PrinterDiagnostic",
            "PCWDiagnostic",
            "AudioRecordingDiagnostic",
            "SearchDiagnostic",
            "NetworkDiagnosticsFileShare",
            "MaintenanceDiagnostic",
            "WindowsMediaPlayerDVDDiagnostic",
            "WindowsMediaPlayerLibraryDiagnostic",
            "WindowsMediaPlayerConfigurationDiagnostic",
            "WindowsUpdateDiagnostic"
        )]
        [string]$Command,
        [Parameter()]
        [switch]$ShowManual
    )

    $troubleshooterCodes = @{
        -1 = "Interruption: The troubleshooter was closed before the troubleshooting tasks were completed."
        0 = "Fixed: The troubleshooter identified and fixed at least one root cause, and no root causes remain in a not fixed state."
        1 = "Present, but not fixed: The troubleshooter identified one or more root causes that remain in a not fixed state. This code is returned even if another root cause was fixed."
        2 = "Not found: The troubleshooter didn't identify any root causes."
    }
    
    if($PSBoundParameters.ContainsKey('ShowManual')) {
    # <manual>

# Data
$data = @"
    Troubleshooting Pack ID;Description;Application or Feature Dependency;Windows 8;Windows RT;Windows 7;Windows Server 2008;Windows Server 2012
    AeroDiagnostic;Troubleshoots problems displaying Aero effects such as transparency.;Aero Display Theme installed;Deprecated;Deprecated;Yes;No;No
    NetworkDiagnosticsDA;Troubleshoots problems connecting to a workplace network over the Internet using DirectAccess.;DirectAccess installed;Yes;Yes;Yes;Yes;Yes
    DeviceDiagnostic;Troubleshoots problems using hardware and access devices connected to the computer.;None;Yes;Yes;Yes;No;No
    HomeGroupDiagnostic;Troubleshoots problems viewing computers or shared files in a homegroup.;HomeGroup installed;Yes;Yes;Yes;No;No
    NetworkDiagnosticsInbound;Troubleshoots problems with allowing other computers to communicate with the target computer through Windows Firewall.;None;Yes;Yes;Yes;Yes;Yes
    NetworkDiagnosticsWeb;Troubleshoots problems connecting to the Internet or to a specific website.;None;Yes;Yes;Yes;Yes;Yes
    IEBrowseWebDiagnostic;Helps the user prevent add-on problems and optimize temporary files and connections.;Internet Explorer installed;Yes;Yes;Yes;No;No
    IESecurityDiagnostic;Helps the user prevent malware, pop-up windows, and online attacks.;Internet Explorer installed;Yes;Yes;Yes;No;No
    NetworkDiagnosticsNetworkAdapter;Troubleshoots problems with Ethernet, wireless, or other network adapters.;None;Yes;Yes;Yes;No;No
    PerformanceDiagnostic;Helps the user adjust settings to improve operating system speed and performance.;None;Deprecated;Deprecated;Yes;No;No
    AudioPlaybackDiagnostic;Troubleshoots problems playing sounds and other audio files.;Audio output device installed;Yes;Yes;Yes;No;No
    PowerDiagnostic;Helps the user adjust power settings to improve battery life and reduce power consumption.;None;Yes;Yes;Yes;No;No
    PrinterDiagnostic;Troubleshoots problems printing.;None;Yes;Yes;Yes;No;No
    PCWDiagnostic;Helps the user configure older programs so that they can run in the current version of Windows.;None;Yes;No;Yes;Yes;Yes
    AudioRecordingDiagnostic;Troubleshoots problems recording audio from a microphone or other input source.;Audio input device installed;Yes;Yes;Yes;No;No
    SearchDiagnostic;Troubleshoots problems with search and indexing using Windows Search.;Search enabled;Yes;Yes;Yes;No;No
    NetworkDiagnosticsFileShare;Troubleshoots problems accessing shared files and folders on other computers over the network.;None;Yes;Yes;Yes;Yes;Yes
    MaintenanceDiagnostic;Helps the user perform maintenance tasks.;None;Yes;Yes;Yes;No;No
    WindowsMediaPlayerDVDDiagnostic;Troubleshoots problems playing a DVD using Windows Media Player.;Windows Media Player installed;Yes;No;Yes;No;No
    WindowsMediaPlayerLibraryDiagnostic;Troubleshoots problems with adding media files to the Windows Media Player library.;Windows Media Player installed;Yes;No;Yes;No;No
    WindowsMediaPlayerConfigurationDiagnostic;Helps the user reset Windows Media Player settings to the default configuration.;Windows Media Player installed;Yes;No;Yes;No;No
    WindowsUpdateDiagnostic;Troubleshoots problems that prevent Windows Update from performing update tasks.;None;Yes;Yes;Yes;No;No
"@ | ConvertFrom-Csv -Delimiter ';' | Out-GridView -Title "msdt.exe manual:" -Wait > $null

    # </manual>
    }

    $troubleshootParams = @{
        FilePath        = "$Env:SystemRoot\system32\msdt.exe"
        ArgumentList    = "-id $Command"
        Wait            = $True
        PassThru        = $True
    }

    "Running: $Command"
    $result = Start-Process @troubleshootParams
    $troubleshooterCodes[$result.ExitCode]
}

# Example usage:
# Invoke-WindowsTroubleshoot -Command NetworkDiagnosticsDA
# Invoke-WindowsTroubleshoot -Command NetworkDiagnosticsDA -ShowManual
