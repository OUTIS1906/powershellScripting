Function Get-CryptoRates {
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
        [string[]]$Currency = @("PLN","EUR","USD")
    )

    $CryptoRates = @{
        BTC   = "Bitcoin"
        ETH   = "Ethereum"
        BUSD  = "BUSD"
        XRP   = "XRP"
        USDT  = "Tether"
        AVAX  = "Avalanche"
        LTC   = "Litecoin"
        SOL   = "Solana"
        GALA  = "Gala"
        DOGE  = "Dogecoin"
        ADA   = "Cardano"
        BNB   = "Binance Coin"
        USDC  = "USD Coin"
        DOT   = "Polkadot"
        UNI   = "Uniswap"
        BCH   = "Bitcoin Cash"
        LINK  = "Chainlink"
        LUNA  = "Terra"
        ICP   = "Internet Computer"
        WBTC  = "Wrapped Bitcoin"
        MATIC = "Polygon"
        XLM   = "Stellar"
    }

    try {
        $tableValues = @()
        foreach ($item in $CryptoRates.GetEnumerator()) {

            $url = "https://min-api.cryptocompare.com/data/price?fsym={0}&tsyms={1}" -f $item.Key, ($Currency -join ",")
            $Rates  = (New-Object System.Net.WebClient).DownloadString($url) | ConvertFrom-Json

            $cryptoObject = [PSCustomObject]@{ 
                'Stack'  = 1
                'Crypto' = $item.Value
                'Symbol' = $item.Key
            }

            foreach ($c in $Currency) {
                $cryptoObject | Add-Member -MemberType NoteProperty -Name $c -Value $Rates.$c
            }

            $tableValues += $cryptoObject
        }  
        $tableValues | Format-Table -AutoSize
    }
    catch {
        "Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0].Exception.Message)"
    }
}

# Example usage:
# Get-CryptoRates
# Get-CryptoRates -Currency PLN, ZAR
