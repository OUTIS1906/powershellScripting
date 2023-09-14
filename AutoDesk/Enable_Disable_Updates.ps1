Function Enable_Disable_Updates{

    Add-Type -AssemblyName PresentationFramework

    $CurrnetUser = ((Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object UserName).UserName)
    $CurrentUserSID = (New-Object System.Security.Principal.NTAccount($CurrnetUser)).Translate([System.Security.Principal.SecurityIdentifier]).Value
    
    $registryFullPath = "registry::HKEY_USERS\$CurrentUserSID\SOFTWARE\Autodesk\ODIS"
    
    if(-not(Test-Path -Path $registryFullPath -PathType Container)){ 
        New-Item -Path $registryFullPath -ItemType Directory -Force | Out-Null 
    } 
    
    $Property = [bool](Get-ItemProperty -Path $registryFullPath -ErrorAction SilentlyContinue).DisableManualUpdateInstall
    
    switch ($Property) {
        $true {
            if(([System.Windows.MessageBox]::Show( "Enable updates?", "Autodesk Updates [DISABLED]","YesNo", "Asterisk" )) -eq "yes"){
                Get-Process *AdskAccess* | ForEach-Object { $_.Kill() }
                Remove-ItemProperty -Path $registryFullPath -Name DisableManualUpdateInstall -Force
                [void] [System.Windows.MessageBox]::Show( "Updates Enabled!", "ODIS Updates", "OK", "None" )
            }
        }
        $false {
            if(([System.Windows.MessageBox]::Show( "Disable updates?", "Autodesk Updates [ENABLED]","YesNo", "Asterisk" )) -eq "yes"){
                Get-Process *AdskAccess* | ForEach-Object { $_.Kill() }
                New-ItemProperty -Path $registryFullPath -Name DisableManualUpdateInstall -PropertyType DWORD -Value 2 -Force | Out-Null
                [void] [System.Windows.MessageBox]::Show( "Updates Disabled!", "ODIS Updates", "OK", "None" )
            }
        } 
    }

}Enable_Disable_Updates
