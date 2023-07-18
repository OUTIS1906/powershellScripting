Function Upload-DropboxFile{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$DestinationFilePath,
        [Parameter(Mandatory)]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [string]$SourceFilePath,
        [string]$AuthToken = "<your auth key> from https://www.dropbox.com/developers/apps/create"
    )

    begin {
        if (-not $DestinationFilePath.StartsWith('/')) {
            $DestinationFilePath = '/' + $DestinationFilePath
        }
    }

    process{

        $dropboxArguments = @{
            "path"       = $DestinationFilePath -replace "\\", "/"
            "mode"       = "add"
            "autorename" = $true
            "mute"       = $false
        } | ConvertTo-Json -Compress
        
        $headers = @{
            "Authorization" = "Bearer $AuthToken"
            "Dropbox-API-Arg" = $dropboxArguments
            "Content-Type" = "application/octet-stream"
        }
        
        try{
            Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $("$SourceFilePath") -Headers $headers
        }
        catch{
            "Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
        }

    }
}
# Upload-DropboxFile -SourceFilePath C:\temp\Test.txt -DestinationFilePath "/Powershell/Test.txt"
