Function Get-PathVariable {
    [CmdletBinding()]
    [Alias('gpvar')]
    [OutputType('PSCustomObject')]
    Param(
        [ValidateSet("All", "User", "Machine")]
        [string]$Scope = "All"
    )

    Function NewEnvPath {
        [CmdletBinding()]
        Param(
            [Parameter(ValueFromPipeline)]
            [string]$Path, [string]$Scope
        )

        Process {
            [PSCustomObject]@{
                Scope        = $Scope
                # Computername = [System.Environment]::MachineName
                UserName     = [System.Environment]::UserName
                Path         = $path
                Exists       = Test-Path $Path
            }
        }
    }

    $user = {
        $paths = [System.Environment]::GetEnvironmentVariable("PATH", "User") -split $char | Where-Object { $PSItem }
        $paths | NewEnvPath -Scope User
    }

    $machine = {
        $paths = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") -split $char | Where-Object { $PSItem }
        $paths | NewEnvPath -Scope Machine
    }

    $all = {
        $paths = [System.Environment]::GetEnvironmentVariable("PATH", "Process") -split $char | Where-Object { $PSItem }
        $paths | NewEnvPath -Scope Process
    }


    #get the path separator character specific to this operating system
    $char = [System.IO.Path]::PathSeparator

    $output = if ($scope -eq "User") {
        Invoke-Command -scriptblock $user
    }
    elseif ($scope -eq "Machine") {
        Invoke-Command -scriptblock $machine
    }
    else {
        Invoke-Command -scriptblock $user
        Invoke-Command -scriptblock $machine
    }

    $output
}

# Example usage:
# Get-PathVariable
