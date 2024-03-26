function Set-FileAssociation {
	[CmdletBinding()]
	Param (
		[Parameter(
			HelpMessage = 'The file name extensions to associate with the program.',
			Mandatory = $true,
			ValueFromPipeline = $true
		)]
		
		[String[]]$FileNameExtensions,

		[Parameter(
			HelpMessage = 'The file type name of the file name extensions.',
			Mandatory = $true
		)]
		
		[ValidateScript({$_ -NotMatch '\s+'})]
		[String]$FileTypeName,

		[Parameter(
			HelpMessage = 'The path to the program to which the file type name is associated.',
			Mandatory = $true
		)]
		[ValidateScript({Test-Path $_})]
		[String]$ProgramPath,
		
		[Switch]$Force
	)

	begin {
		$regRoot = 'Registry::HKEY_CLASSES_ROOT'		
	}

	process {
		foreach ($fileNameExtension in $FileNameExtensions) {
			try{
				New-Item -Path $regRoot -Name $fileNameExtension -Value $FileTypeName -ErrorAction Stop -Force:$Force > $null
			}
			catch{
				Write-Warning "File extension '$fileNameExtension' already exists. Use -Force to overwrite."
				return 
			}
		}

		$commandPath = "$regRoot\$FileTypeName\Shell\Open\Command"
		if (-not (Test-Path $commandPath)) {
			New-Item -Path $commandPath -ItemType ExpandString -ErrorAction Stop -Force:$Force > $null
		}

		Set-ItemProperty -Path $commandPath -Name '(default)' -Value "`"$ProgramPath`" `"%1`"" -ErrorAction Stop > $null
		Write-Host "Completed." -ForegroundColor Green
	}
}
