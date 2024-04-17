Function Extract-ProtectedArchive {
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory          = $true,
            HelpMessage       = "Specifies the path to the protected archive file.",
            ValueFromPipeline = $True
            
        )]
        [ValidateScript({
            if (-not ($_ -match '\.zip$' -and (Test-Path $_ -PathType Leaf))) {
                throw "The specified file must be a valid .zip file and exist."
            }
            $true            
        })]
        [string]$Item,
        
        [Parameter(
            HelpMessage = "Specifies the destination directory where the archive contents will be extracted. Defaults to the current directory."
        )]
        [ValidateScript({
            if (-not (Test-Path -Path $_ -PathType Container)) {
                throw "The specified destination directory does not exist or is not a valid directory."
            }
            $true     
        })]
        [string]$Destination = [System.IO.Directory]::GetCurrentDirectory(),

        [Parameter(
            HelpMessage = "Specifies the mode for the copy operation. Choose from 'Overwrite', 'NoProgressDialog', 'YesToAll', 'PreserveUndo'"
        )]
        [ValidateSet("Overwrite", "NoProgressDialog", "YesToAll", "PreserveUndo","Default")]
        [string]$Mode = "Default"

        
    )

    $modeHash = @{
        'Default'          = 0
        'Overwrite'        = 4
        'NoProgressDialog' = 16
        'YesToAll'         = 128
        'PreserveUndo'     = 256
    }[$Mode]

    try {
        $shell = New-Object -ComObject Shell.Application
        $location = $shell.namespace($Destination)

        $zipFolder = $shell.namespace($item)
        $location.Copyhere($ZipFolder.items(), $modeHash)

        "Info: File|s extracted to {0}" -f $Destination
    }
    catch {
        Write-Warning "Failed to extract archive."
        "Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0].Exception.Message)"
    }
}

# Example usage:
# Extract-ProtectedArchive C:\Temp\CleanUp.zip
# Extract-ProtectedArchive C:\Temp\CleanUp.zip -Destination C:\Temp 
# Extract-ProtectedArchive C:\Temp\CleanUp.zip -Mode NoProgressDialog
