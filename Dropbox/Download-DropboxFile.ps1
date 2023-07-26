Function Download-DropboxFile{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, HelpMessage = "Valid values are:  id => id:123456789 | rev => 123456789 | path => \Powershell\ExampleFile.txt")]
        [string]$SourceFilePath,
        [Parameter(Mandatory)]
        [string]$DownloadDestinationFile,
        [string]$AuthToken = "<your auth key> from https://www.dropbox.com/developers/apps/create"
    )

    process{

        $dropboxArguments = @{
            "path"       = $SourceFilePath -replace "\\", "/"
        } | ConvertTo-Json -Compress
        
        $headers = @{
            "Authorization"   = "Bearer $AuthToken"
            "Dropbox-API-Arg" = $dropboxArguments
            "Content-Type"    = "application/octet-stream"
        }
        
        try{
            Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/download -Method Post -Headers $headers -OutFile $DownloadDestinationFile
        }
        catch{
            "Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
        }
    }
    
}
#Download-DropboxFile -SourceFilePath /powershell/test.xlsx -DownloadDestinationFile C:\temp\file.xlsx
