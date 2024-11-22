function Install-VisualRedistributable {
	[CmdletBinding()]
	param (
		[ValidateSet(2005,2008,2010,2012,2013,2015,2017,2022)]
		[int[]] $Version 	 = @(2005,2008,2010,2012,2013,2015,2017,2022),
		[ValidateSet(86,64)]
		[int[]]	$Architecture = @(86,64)
	)

	$vscppArray = @(
		# X86 packages
		[pscustomobject]@{
			version 	 = 2005
			architecture = 86
			parameters	 = "/Q"
			urlLink		 = "download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.EXE"
		},
		[pscustomobject]@{
			version 	 = 2008
			architecture = 86
			parameters	 = "/qb"
			urlLink		 = "download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe"
		},
		[pscustomobject]@{
			version 	 = 2010
			architecture = 86
			parameters	 = "/passive /norestart"
			urlLink		 = "download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe"
		},
		[pscustomobject]@{
			version 	 = 2012
			architecture = 86
			parameters	 = "/install /passive /norestart"
			urlLink		 = "download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe"
		},
		[pscustomobject]@{
			version 	 = 2013
			architecture = 86
			parameters	 = "/install /passive /norestart"
			urlLink		 = "download.visualstudio.microsoft.com/download/pr/10912113/5da66ddebb0ad32ebd4b922fd82e8e25/vcredist_x86.exe"
		},
		[pscustomobject]@{
			version 	 = 2015
			architecture = 86
			parameters	 = "/install /passive /norestart"
			urlLink		 = "download.microsoft.com/download/6/D/F/6DF3FF94-F7F9-4F0B-838C-A328D1A7D0EE/vc_redist.x86.exe"
		},
		[pscustomobject]@{
			version 	 = 2017
			architecture = 86
			parameters	 = "/install /passive /norestart"
			urlLink		 = "download.visualstudio.microsoft.com/download/pr/11100230/15ccb3f02745c7b206ad10373cbca89b/VC_redist.x64.exe"
		},
		[pscustomobject]@{
			version 	 = 2022
			architecture = 86
			parameters	 = "/install /passive /norestart"
			urlLink		 = "aka.ms/vs/17/release/vc_redist.x86.exe"
		},
		# X64 packages
		[pscustomobject]@{
			version 	 = 2005
			architecture = 64
			parameters	 = "/Q"
			urlLink		 = "download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x64.EXE"
		},
		[pscustomobject]@{
			version 	 = 2008
			architecture = 64
			parameters	 = "/qb"
			urlLink		 = "download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe"
		},
		[pscustomobject]@{
			version 	 = 2010
			architecture = 64
			parameters	 = "/passive /norestart"
			urlLink		 = "download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe"
		},
		[pscustomobject]@{
			version 	 = 2012
			architecture = 64
			parameters	 = "/install /passive /norestart"
			urlLink		 = "download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe"
		},
		[pscustomobject]@{
			version 	 = 2013
			architecture = 64
			parameters	 = "/install /passive /norestart"
			urlLink		 = "download.visualstudio.microsoft.com/download/pr/10912041/cee5d6bca2ddbcd039da727bf4acb48a/vcredist_x64.exe"
		},
		[pscustomobject]@{
			version 	 = 2015
			architecture = 64
			parameters	 = "/install /passive /norestart"
			urlLink		 = "download.microsoft.com/download/6/D/F/6DF3FF94-F7F9-4F0B-838C-A328D1A7D0EE/vc_redist.x64.exe"
		},
		[pscustomobject]@{
			version 	 = 2017
			architecture = 64
			parameters	 = "/install /passive /norestart"
			urlLink		 = "download.visualstudio.microsoft.com/download/pr/11100229/78c1e864d806e36f6035d80a0e80399e/VC_redist.x86.exe"
		},
		[pscustomobject]@{
			version 	 = 2022
			architecture = 64
			parameters	 = "/install /passive /norestart"
			urlLink		 = "aka.ms/vs/17/release/vc_redist.x64.exe"
		}
	)

	$forInstall = $vscppArray.Where( {($_.version -in $Version) -and ($_.architecture -in $Architecture) }) | 
		Sort-Object -Property version

	$tempPath = "C:\Temp\Powershell"
	if(-not(Test-Path -Path $tempPath -PathType Container)) {
		New-Item -Path $tempPath -ItemType Directory -Force > Out-Null
	}

	foreach ($item in $forInstall) {
		
		$fileName = "microsoft-visual-redistributable-c++.{0}.x{1}.exe" -f $item.version, $item.architecture
		$filePath = [io.path]::combine($tempPath,$fileName)

		$urlPath  = "https://" + $item.urlLink
		$activity = "Microsoft Visual C++ Redistributable {0} X{1}" -f $item.version, $item.architecture

		Write-Progress -Activity $activity -PercentComplete 50 -Status 'Downloading:'

		$webCli = [Net.WebClient]::new()
		$webCli.DownloadFile($urlPath,$filePath)

		Write-Progress -Activity $activity -PercentComplete 100 -Status "Instaling:"

		$result = Start-Process -FilePath $filePath -ArgumentList $item.parameters -Wait -PassThru

		Write-Progress -Completed -Activity $activity

		if ($result.ExitCode -in (0)) {
			Write-Host ("[+] - Microsoft Visual C++ Redistributable {0} X{1}" -f $item.version, $item.architecture)
		}
		else {
			"[-] - Microsoft Visual C++ Redistributable {0} X{1}" -f $item.version, $item.architecture
		}

		<#
			"Version: " + $item.ver
		"Code	: " + $result.ExitCode
		"Message: " + ([ComponentModel.Win32Exception] $result.ExitCode).Message

		#>

	}

}

# Example usage:
# Install-VisualRedistributable
# Install-VisualRedistributable -Version 2010
# Install-VisualRedistributable -Architecture 64
# Install-VisualRedistributable -Version 2010 -Architecture 86
