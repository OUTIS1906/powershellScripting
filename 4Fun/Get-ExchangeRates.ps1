Function Get-ExchangeRates {
    [CmdletBinding()]
    param (
        [Parameter(
            HelpMessage = "Provide currency code, eg: PLN, EUR, USD"
        )]
        [ValidateSet("AUD", "BRL", "CAD", "CHF", "CLP", "CNY", "CZK",
                    "DKK", "EUR", "GBP", "HKD", "HUF", "IDR", "ILS",
                    "INR", "JPY", "KRW", "MXN", "MYR", "NOK", "NZD",
                    "PHP", "PKR", "PLN", "RUB", "SEK", "SGD", "THB",
                    "TRY", "TWD", "USD", "ZAR")
        ]
        [string]$Currency = 'PLN'
    )

    try {
        $tableValues = @()
        [xml]$Rates  = (New-Object System.Net.WebClient).DownloadString("http://www.floatrates.com/daily/$Currency.xml")
        foreach ($item in $Rates.channel.item) {
            $exchangeObject = [PSCustomObject]@{
                'Currency' = "{0} - {1}" -f $item.targetCurrency, $item.targetName
                'Rate'     = $item.exchangeRate
                'Inverse'  = $item.inverseRate
                'Date'     = $item.pubDate
            }
            $tableValues += $exchangeObject
        }
        $tableValues | Sort-Object -Property Currency | Format-Table -AutoSize
    }
    catch {
        "Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0].Exception.Message)"
    }

}

# Example usage:
# Get-ExchangeRates
# Get-ExchangeRates -Currency USD
