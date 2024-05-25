Function Find-AlternativeDataStream {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Path = "./", #[Environment]::CurrentDirectory,
		[switch]$Recurse,
        [switch]$ShowDefault
    )

    $files = Get-ChildItem -Recurse:$Recurse -Path $Path -ErrorAction SilentlyContinue

    foreach ($file in $files){

        $streams = Get-Item -Path $file.Fullname -stream * | Where-Object { $ShowDefault.IsPresent -or $_.Stream -ne ':$DATA' }

        if ($null -ne $streams){

            foreach ($stream in $streams){

                $streamContent = Get-Content -path $file.fullname -stream $stream.Stream

				$fileObject = New-Object PSObject
				$fileObject | Add-Member -MemberType NoteProperty -Name "FileName" -Value $file.FullName
				$fileObject | Add-Member -MemberType NoteProperty -Name "IsFile" -Value (-not $stream.PSIsContainer)
				$fileObject | Add-Member -MemberType NoteProperty -Name "IsFolder" -Value $stream.PSIsContainer
				$fileObject | Add-Member -MemberType NoteProperty -Name "StreamLength" -Value $stream.Length
				$fileObject | Add-Member -MemberType NoteProperty -Name "StreamName" -Value $stream.Stream
				$fileObject | Add-Member -MemberType NoteProperty -Name "StreamContent" -Value $streamContent

                Write-Output $fileObject | Format-List
            }
        }
    }
}


Function Add-AlternativeDataStream {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [string]$StreamName = ':$DATA',
        [Parameter()]
        #[ValidateNotNullOrEmpty()] #$null value can reset existing one when -Overwrite is passed.
        [string]$Content,
        [switch]$Overwrite    
        
    )

    if (Test-Path $Path -PathType Leaf) {

        if(-not ($PSBoundParameters['StreamName'])) {
            if ((Read-Host -Prompt 'Do you want to add data to default Stream:$DATA, y/n ' ) -ne 'y' ) { 
                "Skipping..."
                return
            }
        }

        if($PSBoundParameters.ContainsKey('Overwrite')) {
            "Overwriting..."
            Set-Content -Path $Path -Stream $StreamName  -Value $Content -Force
        }
        else {
            "Adding..."
            Add-Content -Path $Path -Stream $StreamName  -Value $Content -Force
        }

        Write-Output "ADS:$StreamName written to file '$Path'"
    }
    else {
        Write-Warning "Item: '$Path' not found."
    }

}

# Example usage:
# Find-AlternativeDataStream 
# Find-AlternativeDataStream -Path "C:\Temp\Powershell\" -ShowDefault
# Find-AlternativeDataStream -Path "C:\Temp\Powershell\" -Recurse -ShowDefault

# Add-AlternativeDataStream -Path .\file.txt -StreamName "new-steam" -Content "new-content"
# Add-AlternativeDataStream -Path .\file.txt -StreamName "new-steam" -Content $null -Overwrite
