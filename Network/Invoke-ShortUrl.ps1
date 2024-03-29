function Create-ShortUrl {
  [CmdletBinding()]
  param (
      [Parameter(
          Mandatory          = $true,
          HelpMessage        = "Enter URL address(es).",
          ValueFromPipeline  = $true
      )]
      [string[]]$Url
  )

  $outputObject = @()

  foreach ($item in $Url) {

      $body = @{
          url         = $item
          description = "string"
          domain      = "tinyurl.com"
      }

      try {
          $shortLink = Invoke-RestMethod -Uri "http://tinyurl.com/api-create.php" -ContentType "application/json" -Body $body -ErrorAction Stop
        
          $outputObject += [pscustomobject]@{
              BaseLink  = $item
              ShortLink = $shortLink
          }
      }
      catch {
          Write-Warning "Failed to create short link for $item."
      }
  }
  return $outputObject
}

# Example usage:
# Create-ShortUrl -Url 'google.pl', 'https://youtube.pl'



function Expand-ShortUrl {
  [CmdletBinding()]
  param (
      [Parameter(
          Mandatory          = $true,
          HelpMessage        = "Enter Tiny URL address(es).",
          ValueFromPipeline  = $true
      )]
      [string[]]$Url
  )

  $outputObject = @()

  foreach ($item in $Url) {
      try {
          $resolvedUrl = (Invoke-WebRequest -UseBasicParsing -Uri $item -AllowInsecureRedirect -ErrorAction Stop).baseresponse.RequestMessage.RequestUri.OriginalString

          $outputObject += [pscustomobject]@{
              ShortUrl  = $item
              BaseLink  = $resolvedUrl
          }
      }
      catch {
          Write-Warning "Failed to resolve short link for $item."
      }
  }
  return $outputObject
}

# Example usage:
# Expand-ShortUrl -Url 'https://tinyurl.com/75bsz', 'https://tinyurl.com/'
