function Get-AuditSettings {
    [CmdletBinding()]
    param (
        [Parameter(
            ParameterSetName = "Category",
            Mandatory = $true
        )]
        [ValidateSet(
            "Account Management","Logon/Logoff","Object Access","Account Logon","System","Privilege Use","Detailed Tracking","Policy Change","DS Access"
        )]
        [string]$Category,
        
        [Parameter(
            ParameterSetName = "SubCategory",
            Mandatory = $true
        )]
        [ValidateSet(
            "Security System Extension","System Integrity","IPsec Driver","Other System Events","Security State Change","Logon","Logoff","Account Lockout","IPsec Main Mode","IPsec Quick Mode","IPsec Extended Mode","Special Logon","Other Logon/Logoff Events","Network Policy Server","User / Device Claims","Group Membership","File System","Registry","Kernel Object","SAM","Certification Services","Application Generated","Handle Manipulation","File Share","Filtering Platform Packet Drop","Filtering Platform Connection","Other Object Access Events","Detailed File Share","Removable Storage","Central Policy Staging","Non Sensitive Privilege Use","Other Privilege Use Events","Sensitive Privilege Use","Process Creation","Process Termination","DPAPI Activity","RPC Events","Plug and Play Events","Token Right Adjusted Events","Audit Policy Change","Authentication Policy Change","Authorization Policy Change","MPSSVC Rule-Level Policy Change","Filtering Platform Policy Change","Other Policy Change Events","Computer Account Management","Security Group Management","Distribution Group Management","Application Group Management","Other Account Management Events","User Account Management","Directory Service Access","Directory Service Changes","Directory Service Replication","Detailed Directory Service Replication","Kerberos Service Ticket Operations","Other Account Logon Events","Kerberos Authentication Service","Credential Validation"
        )]
        [string]$SubCategory,

        [Parameter(
            ParameterSetName = "AllDDetailed"
        )]
        [switch]$All
    )


    $audit = switch ($PSCmdlet.ParameterSetName) {
        'Category' {
            auditpol.exe /get /category:"$Category" /r
        }
        'SubCategory' {
            auditpol.exe /get /subcategory:"$SubCategory" /r
        }
        'AllDDetailed' {
            auditpol.exe /get /category:* /r
        }
    }

    $audit | ConvertFrom-Csv

}

# Example usage:
# Get-AuditSettings -All
# Get-AuditSettings -Category 'Account Logon'
