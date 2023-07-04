Function Enable-NewOfficeUI{
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet("access", "excel", "onenote", "outlook", "powerpoint", "project", "publisher", "visio", "word")]
        [string[]]$Applications = @(
            "access",
            "excel",
            "onenote",
            "outlook",
            "powerpoint",
            "project",
            "publisher",
            "visio",
            "word"
        ),
        [switch]$Disable
    )

    $RegistryPath = "HKCU:\Software\Microsoft\Office\16.0\Common\ExperimentConfigs\ExternalFeatureOverrides"

    $Properties = @(
        "Microsoft.Office.UXPlatform.FluentSVRefresh",
        "Microsoft.Office.UXPlatform.RibbonTouchOptimization",
        "Microsoft.Office.UXPlatform.FluentSVRibbonOptionsMenu"
    )

    $value = if($Disable.IsPresent){'false'}else{'true'}

    $output = @{}
    
    foreach ($app in $Applications) {
        $AppRegistryPath = Join-Path -Path $RegistryPath -ChildPath $app
    
        New-Item -Path $AppRegistryPath -ItemType RegistryKey -Force | Out-Null
    
        foreach ($prop in $Properties) {
            Set-ItemProperty -Path $AppRegistryPath -Name $prop -Value $value -Force
        }
        $Output[$app] = $Value
    }

    $Output | Format-Table

}Enable-NewOfficeUI
