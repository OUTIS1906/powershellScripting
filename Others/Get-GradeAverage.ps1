function Get-GradeAverage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
        [array]$Grades
    )
    
    $totalWeighted = 0
    $totalWeight = 0

    foreach ($entry in $Grades) {
        if ($entry.Count -ne 2) {
            Write-Host "Invalid input format. Use (Grade, Weight) pairs."
            return $null
        }
        $grade, $weight = $entry
        $totalWeighted += $grade * $weight
        $totalWeight += $weight
    }

    if ($totalWeight -eq 0) {
        Write-Host "Total weight cannot be zero."
        return $null
    }

    return $totalWeighted / $totalWeight
}

# Example usage
Get-GradeAverage (3.5,4) (4.0,2 ) (4.0,2 ) (4.5,2 ) (3.5,4 ) (3.5,2 ) (4.5,3 ) (5.0,2 ) (5.0,3 ) (4.0,3 ) (4.0,3)

Get-GradeAverage `
(3.5,4)`
(4.0,2)`
(4.0,2)`
(4.5,2)`
(3.5,4)`
(3.5,2)`
(4.5,3)`
(5.0,2)`
(5.0,3)`
(4.0,3)`
(4.0,3)
