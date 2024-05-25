function Get-GptResponse {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$AuthToken = "<token>",

        [ValidateSet(
            "gpt-4-turbo",
            "gpt-4",
            "gpt-3.5-turbo"
        )]
        [string]$Model = "gpt-3.5-turbo",

        [switch]$TokenUsage
    )

    # Simple stats:
    $token_usage = [PSCustomObject]@{
        Model   = $Model
        Total   = 0
        User    = 0        
        Chat    = 0 
    }

    $endpoint = "https://api.openai.com/v1/chat/completions"

    $headers = @{
        "Content-Type"  = "application/json"
        "Authorization" = "Bearer $AuthToken"
    }

    while ($true) {

        $user_message = Read-Host -Prompt "You"
        
        if ($user_message -eq "exit") {
            "Exiting..."
            
            if ($PSBoundParameters.ContainsKey('TokenUsage')) {
                $token_usage.Total = $token_usage.User + $token_usage.Chat
                $token_usage | Format-List
            }
            return
        }

        elseif ($user_message -eq 'cls') {
            [console]::Clear()
            continue
        }

        else {
            $payload = @{
                model    = $model
                messages = @(
                    @{
                        role    = "user"
                        content = $user_message
                    }
                )
                temperature = 0.2
                top_p       = 0.3
            } | ConvertTo-Json

            try {
                $response = Invoke-RestMethod -Uri $endpoint -Method Post -Headers $headers -Body $payload -ErrorAction Stop

                $assistant_response = $response.choices[0].message.content
                "GPT: {0}" -f $assistant_response
                
                # Update token usage
                $token_usage.user += $user_message.length
                $token_usage.chat += $assistant_response.length
            }
            catch {
                Write-Warning "API Error: "
                ($Error[0].ErrorDetails.Message | ConvertFrom-Json ).Error | Format-List
                return
            }
        }
    }
}

# Example usage:
# Get-GptResponse
# Get-GptResponse -AuthToken <token>
# Get-GptResponse -Model gpt-4-turbo -TokenUsage
