function New-SandboxFile {
        <#
        .SYNOPSIS
        Creates a configuration file for Windows Sandbox with various customizable options such as virtual GPU, networking, audio/video input, memory size, mapped folders, and more.
    
        .DESCRIPTION
        This function generates an XML configuration file for use with Windows Sandbox. You can enable or disable features like vGPU, networking, audio input, and more through parameters.
        The function also allows you to map folders from the host machine to the sandbox and execute a logon command on sandbox startup. 
    
        .PARAMETER vGpu
        Enable or disable the virtualized GPU (vGPU) in the sandbox. If disabled, Windows Advanced Rasterization Platform (WARP) will be used instead.
    
        .PARAMETER Networking
        Enable or disable network access within the sandbox.
    
        .PARAMETER AudioInput
        Enable or disable sharing the host's microphone input with the sandbox.
    
        .PARAMETER VideoInput
        Enable or disable sharing the host's webcam input with the sandbox.
    
        .PARAMETER ProtectedClient
        Enable or disable increased security settings for the Remote Desktop Protocol (RDP) session to the sandbox.
    
        .PARAMETER ClipboardRedirection
        Enable or disable clipboard redirection between the host and sandbox, allowing text and files to be copied/pasted between them.
    
        .PARAMETER PrinterRedirection
        Enable or disable printer redirection, allowing printers on the host machine to be shared with the sandbox.
    
        .PARAMETER MemoryInMB
        The amount of memory (in MB) to assign to the sandbox. This must be between 1024 MB and the maximum available physical memory on the system.
    
        .PARAMETER LogonCommand
        A command to execute when Windows Sandbox starts.
    
        .PARAMETER ReadOnly
        If specified, the mapped folder will be read-only within the sandbox.
    
        .PARAMETER OutFile
        The output file where the sandbox configuration will be saved. If not specified, a temporary file will be created.

        .PARAMETER AllEnabled
        If specified, 'vGpu', 'Networking', 'AudioInput', 'VideoInput', 'ProtectedClient', 'ClipboardRedirection', 'PrinterRedirection' are enabled with one switch instead of using separately.
    
        .EXAMPLE
        New-SandboxFile -vGpu -Networking -MemoryInMB 2048 -LogonCommand "C:\path\to\command.exe"
    
        Creates a Windows Sandbox configuration with virtual GPU enabled, network access, 2 GB of memory, and a logon command that runs `command.exe` when the sandbox starts.
    
        .EXAMPLE
        New-SandboxFile -MappedFolders -HostFolder "C:\Users\Documents" -SandboxFolder "C:\SandboxDocuments" -ReadOnly $true -OutFile "C:\path\to\output.wsb"
    
        Creates a Windows Sandbox configuration with mapped folders, sharing "C:\Users\Documents" from the host to "C:\SandboxDocuments" in the sandbox, with read-only access. The configuration is saved to the specified output file.
    
        .NOTES
        The function requires PowerShell 5.1 or higher and Windows 10 or later to work properly with Windows Sandbox.
    
        #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [Parameter(ParameterSetName = "Default")]
        [switch]$vGpu,
        
        [Parameter()]
        [Parameter(ParameterSetName = "Default")]
        [switch]$Networking,

        [Parameter()]
        [Parameter(ParameterSetName = "Default")]
        [switch]$AudioInput,

        [Parameter()]
        [Parameter(ParameterSetName = "Default")]
        [switch]$VideoInput,

        [Parameter()]
        [Parameter(ParameterSetName = "Default")]
        [switch]$ProtectedClient,

        [Parameter()]
        [Parameter(ParameterSetName = "Default")]
        [switch]$ClipboardRedirection,

        [Parameter()]
        [Parameter(ParameterSetName = "Default")]
        [switch]$PrinterRedirection,

        [Parameter()]
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "AllEnabled")]
        [ValidateScript({
            $min = 1024
            $max = ((Get-CimInstance -Class "cim_physicalmemory" | Measure-Object -Property Capacity -Sum).Sum / 1MB)
    
            if ($PSItem -lt $min -or $PSItem -gt $max) {
                throw New-Object System.NotSupportedException("Capacity not in range: $min - $max MB")
            }
            return $true
        })]
        [int]$MemoryInMB = 4096,

        [Parameter()]
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "AllEnabled")]
        [string]$LogonCommand,

        [Parameter()]
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "AllEnabled")]
        [switch]$MappedFolders,

        
        [Parameter()]
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "AllEnabled")]
        
        [string]$OutFile,

        [Parameter()]
        [Parameter(ParameterSetName = "AllEnabled")]
        [switch]$AllEnabled


    )
    
    # Dynamic params: HostFolder, SandboxFolder, ReadOnly
    dynamicparam 
    {
        # Params dictionary
        $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary

        if ($MappedFolders.IsPresent) 
        {
            # Collection params
            $paramAttributes = New-Object -Type System.Management.Automation.ParameterAttribute
            $paramAttributes.Mandatory = $true

            # Collection attr
            $paramAttributesCollect = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
            $paramAttributesCollect.Add($paramAttributes)

            # Param:HostFolder
            $dynParam1 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter(
                "HostFolder", [string], $paramAttributesCollect
            )

            # Param:SandboxFolder
            $dynParam2 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter(
                "SandboxFolder", [string], $paramAttributesCollect
            )

            # Param:ReadOnly
            $dynParam3 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter(
                "ReadOnly", [bool], $paramAttributesCollect
            )

            # Param adding to dict
            $paramDictionary.Add("HostFolder", $dynParam1)
            $paramDictionary.Add("SandboxFolder", $dynParam2)
            $paramDictionary.Add("ReadOnly", $dynParam3)
        }

        return $paramDictionary
    }


    begin 
    {

        if ($PSCmdlet.ParameterSetName -eq 'AllEnabled') {
            @('vGpu', 'Networking', 'AudioInput', 'VideoInput', 'ProtectedClient', 'ClipboardRedirection', 'PrinterRedirection') | ForEach-Object { Set-Variable -Name $PSItem -Value $true }
        }
        

        if ($MappedFolders.IsPresent) 
        {
            $HostFolder     = $PSBoundParameters['HostFolder']
            $SandboxFolder  = $PSBoundParameters['SandboxFolder']
            $ReadOnly       = $PSBoundParameters['ReadOnly']

            if (-not (Test-Path -Path $HostFolder -PathType Container))
            {
                throw New-Object System.NotSupportedException("HostFolder: cannot locate: $HostFolder.")
                # Write-Error "HostFolder: cannot locate: $HostFolder.";
                # break;;
                
            }
        }
    }

    process 
    {
         # $PSBoundParameters.GetEnumerator()
        
        $boolMap = @{
            1 = 'Enable'
            0 = 'Disable'
            #2 = 'Default'
        }

        # New XML
        $xmlStructure = [System.Xml.XmlDocument]::new()

        # <Configuration>
        $configurationElement = $xmlStructure.CreateElement("Configuration")
        $xmlStructure.AppendChild($configurationElement) > $null


        # Basic (no-nested) settings
        $settings = @{
            'vGPU'                  = $boolMap[$vGPU.IsPresent                 -as [int]]
            'Networking'            = $boolMap[$Networking.IsPresent           -as [int]]
            'AudioInput'            = $boolMap[$AudioInput.IsPresent           -as [int]]
            'VideoInput'            = $boolMap[$VideoInput.IsPresent           -as [int]]
            'ProtectedClient'       = $boolMap[$ProtectedClient.IsPresent      -as [int]]
            'ClipboardRedirection'  = $boolMap[$ClipboardRedirection.IsPresent -as [int]]
            'PrinterRedirection'    = $boolMap[$PrinterRedirection.IsPresent   -as [int]]
            'MemoryInMB'            = $MemoryInMB  # no boolMap
        }
        
        foreach ($item in $settings.Keys)
        {
            $itemElement = $xmlStructure.CreateElement($item)
            $itemElement.InnerText = $settings[$item]
            $configurationElement.AppendChild($itemElement) > $null
        }
        
        # <MappedFolders>
        if($MappedFolders) 
        {

            $mappedFoldersElement = $xmlStructure.CreateElement("MappedFolders")
            $mappedFolderElement = $xmlStructure.CreateElement("MappedFolder")

            $mappedFolderDetails = @{
                HostFolder    = $HostFolder
                SandboxFolder = $SandboxFolder
                ReadOnly      = $ReadOnly
            }


            foreach ($key in $mappedFolderDetails.Keys) {
                $itemElement = $xmlStructure.CreateElement($key)
                $itemElement.InnerText = $mappedFolderDetails[$key]
                $mappedFolderElement.AppendChild($itemElement) > $null
            }

            $mappedFoldersElement.AppendChild($mappedFolderElement)  > $null
            $configurationElement.AppendChild($mappedFoldersElement) > $null

        }

        # <LogonCommand>
        if ($LogonCommand)
        {

            $logonCommandElement = $xmlStructure.CreateElement("LogonCommand")
            $commandElement = $xmlStructure.CreateElement("Command")

            $commandElement.InnerText = $LogonCommand

            $logonCommandElement.AppendChild($commandElement)       > $null
            $configurationElement.AppendChild($logonCommandElement) > $null
        }
    }

    
    end
    {
        if (-not $OutFile)
        {
            $saveFile = [io.path]::GetTempFileName() -replace "\.tmp$", ".wsb"
        }

        else {
            $fileName = [io.path]::GetFileNameWithoutExtension($OutFile)
            $saveFile = [io.path]::Combine($PSScriptRoot,"$fileName.wsb")
        }

        # Save
        $xmlStructure.Save($saveFile)

        Write-Host "Output file: $saveFile"
    }

}

# Example usage:
New-SandboxFile -AllEnabled -OutFile sandbox.wsb
New-SandboxFile -MemoryInMB 10024  -Networking -LogonCommand "C:\windows\shutdown.exe -s -t 0"
New-SandboxFile -AllEnabled -MappedFolders -HostFolder C:\Temp -SandboxFolder C:\Temp -ReadOnly $true
