Function Get-DropboxFiles{
    [CmdletBinding()]
    param (
        [string]$RootPath = "",
        [string]$AuthToken = "<your auth key> from https://www.dropbox.com/developers/apps/create"
    )

    begin {
        if ((-not $RootPath.StartsWith('/'))-and (-not[string]::IsNullOrEmpty($RootPath))) {
            $RootPath = '/' + $RootPath
        }
    }

    process{

        $dropboxArguments = @{
            "include_deleted"                       = $false
            "include_has_explicit_shared_members"   = $false
            "include_media_info"                    = $false
            "include_mounted_folders"               = $true
            "include_non_downloadable_files"        = $true
            "path"                                  = $RootPath -replace "\\", "/"
            "recursive"                             = $false
        } | ConvertTo-Json -Compress
        
        $headers = @{
            "Authorization" = "Bearer $AuthToken"
            "Content-Type" = "application/json"
        }
        
        try{
            $response = Invoke-RestMethod -Uri https://api.dropboxapi.com/2/files/list_folder -Method Post -Headers $headers -Body $dropboxArguments
            Write-Output $response.entries
        }
        catch{
            "Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
        }
    }
    
}Get-DropboxFiles
