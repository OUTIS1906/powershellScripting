function Set-WindowState {
    param(
        [Parameter()]
        [ValidateSet('FORCEMINIMIZE', 'HIDE', 'MAXIMIZE', 'MINIMIZE', 'RESTORE', 
                     'SHOW', 'SHOWDEFAULT', 'SHOWMAXIMIZED', 'SHOWMINIMIZED', 
                     'SHOWMINNOACTIVE', 'SHOWNA', 'SHOWNOACTIVATE', 'SHOWNORMAL')]
        [Alias('Style')]
        [String] $State = 'SHOW',
        
        [Parameter(ValueFromPipelineByPropertyname='True')]
        [System.IntPtr] $MainWindowHandle = (Get-Process –id $pid).MainWindowHandle
    
    )
    
    $WindowStates = @{
        'FORCEMINIMIZE'   = 11
        'HIDE'            = 0
        'MAXIMIZE'        = 3
        'MINIMIZE'        = 6
        'RESTORE'         = 9
        'SHOW'            = 5
        'SHOWDEFAULT'     = 10
        'SHOWMAXIMIZED'   = 3
        'SHOWMINIMIZED'   = 2
        'SHOWMINNOACTIVE' = 7
        'SHOWNA'          = 8
        'SHOWNOACTIVATE'  = 4
        'SHOWNORMAL'      = 1
    }
        
    $Win32ShowWindowAsync = Add-Type –memberDefinition @"
[DllImport("user32.dll")] 
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow); 
"@ -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru
    
    $Win32ShowWindowAsync::ShowWindowAsync($MainWindowHandle, $WindowStates[$State]) > $null
    Write-Verbose ("Set Window State on '{0}' to '{1}' " -f $MainWindowHandle, $State)
}

# Example usage:
# Get-Process winword | Set-WindowState -State MAXIMIZE
