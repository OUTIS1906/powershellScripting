function Install-Fonts {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ 
            if (-not (Test-Path $_)) {
                throw "Path not found: $PSItem"
            }

            $validExtensions = '.ttf', '.otf'
            if ([System.IO.Path]::GetExtension($PSItem) -notin $validExtensions) {
                throw "Invalid font file extension: $PSItem"
            }

            return $true
        })]
        [System.IO.FileInfo]$FontFile
    )

    begin {
        $fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
    }

    process {
        $fileName = $FontFile.Name
        if (-not (
            (Test-Path -Path "$env:localappdata\Microsoft\Windows\Fonts\$fileName" -PathType Leaf) -or
            (Test-Path -Path "$env:windir\Fonts\$fileName")
        )) {
            try {
                $fonts.CopyHere($FontFile.FullName)
                Write-Host "✅ Installed: $fileName" -ForegroundColor Green
            }
            catch {
                Write-Host "❌ Failed: $fileName" -ForegroundColor Red
            }
        }
        else {
            Write-Host "⛔ Already installed: $fileName" -ForegroundColor Yellow
        }
    }
}

# ✅ -> "$([char]0x2705)"
# ❌ -> "$([char]0x274C)"
# ⛔ -> "$([char]0x26D4)"

# Example usage:
# Install-Fonts -FontFile .\0xProtoNerdFont-Bold.ttf
# Get-Item * | Install-Fonts
