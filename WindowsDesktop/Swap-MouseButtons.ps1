Function Swap-MouseButtons {
    [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") > $null

$SwapButtons = Add-Type -MemberDefinition @'
[DllImport("user32.dll")]
public static extern bool SwapMouseButton(bool swap);
'@ -Name "NativeMethods" -Namespace "PInvoke" -PassThru

    $SwapButtons::SwapMouseButton(!([System.Windows.Forms.SystemInformation]::MouseButtonsSwapped))
} 

# Example usage:
# Swap-MouseButtons
