Function Create-DocxFromHTML{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[string]$Url,
		[string]$OutFile = "C:\Temp\File.docx"
	)
	Function GetMainTagContent($url){

		# Fortesting
		#$Url = "https://oferta.urk.edu.pl/index/site/3894"
		$pattern = "(?<=<main\b[^>]*>)([\s\S]*?)(?=</main>)"
	
		try{
			$content = (Invoke-WebRequest -Uri $Url -ErrorAction Stop).Content
			$matches = [regex]::Match($content, $pattern)
	
			if ($matches.Success) {
				$htmlContent = $matches.Value
				$wordOutput = "<html><body>$htmlContent</body></html>"
	
				return $wordOutput
	
			} else {
				return $false
			}
		}
		catch{
			return $false
		}
	}

	try{
		#Create Word Com instance
		$wordApp = New-Object -ComObject Word.Application

		# Set visibility 
		$wordApp.Visible = $true # $false ( $true is only for testing)

		# Create new document
		$document = $wordApp.Documents.Add()
	}
	catch{
		"Cannot create Word instance..."
		throw "Cannot create Word instance..."
	}


	$html2Doc = GetMainTagContent($Url)
	if ($html2Doc -ne $false) {

		$htmlTempFile = Join-Path -Path $Env:temp -ChildPath "testHTML.html"

		$html2Doc | Out-File -FilePath $htmlTempFile -Encoding utf8 -Force

		# Insert the HTML file into the Word document
		$range = $document.Range()
		$range.InsertFile($htmlTempFile)

		# Save the document as DOCX format
		New-Item -Path $OutFile -ItemType File -Force | Out-Null
		#New-item $docxPath -Force -ItemType File
		Read-Host "Press any key to proceed..."
		$document.SaveAs([ref]$OutFile, [ref]16)  # 16 represents the DOCX file format

		"Saved to $OutFile"

	}
	else{
		"$Url content load issue"
	}

	# Close and quit Word application
	$document.Close()
	$wordApp.Quit()

	# Cleannig ojeect and variables
	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($range) 	   | Out-Null
	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($document)  | Out-Null
	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($wordApp)   | Out-Null

}Create-DocxFromHTML
