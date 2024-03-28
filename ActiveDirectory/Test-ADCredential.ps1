function Test-ADCredential {
    Param
    (
        [System.Management.Automation.PSCredential]$Credentials = (Get-Credential -Message "Provide domain credentials")
    )

    try {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        $domian = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
        switch ($domian.ValidateCredentials($Credentials.Username, $Credentials.GetNetworkCredential().Password)) {
            $true   { Write-Host "$($Credentials.Username) - Credentials are valid." -ForegroundColor Green    }
            $false  { Write-Host "$($Credentials.Username) - Credentials are not valid." -ForegroundColor Red  }
            default { Write-Host "An issue occured." -ForegroundColor Yellow        }
        }
    }
    catch { 
        Write-Warning "Domain is unavaialble."
    }
    
}Test-ADCredential

# Example usage:
# Test-ADCredential -Credentials (Get-Credential)
