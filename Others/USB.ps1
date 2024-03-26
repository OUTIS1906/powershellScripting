Function Format-USB {

    $USBDrives = Get-Disk | Where-Object { $_.BusType -eq 'USB' } | Out-GridView -Title 'Select USB Drive to Format' -OutputMode Single 

    if ($USBDrive) {
        $Partition = $USBDrive | Clear-Disk -RemoveData -RemoveOEM -Confirm:$false | New-Partition -AssignDriveLetter -UseMaximumSize
        Format-Volume -Partition $Partition -FileSystem FAT32 -Force -Confirm:$false
    }
    else {
        Write-Warning "No USB drive selected or available for formatting."
    }
}


Function Create-BootableUSB {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [string]$ImagePath
    )

    # Select the USB drive to format
    $USBDrive = Get-Disk | Where-Object { $_.BusType -eq 'USB' } | Out-GridView -Title 'Select USB Drive to Format' -OutputMode Single

    # Format the selected USB drive
    $USBDrive | Clear-Disk -RemoveData -RemoveOEM -Confirm:$false -PassThru |
        New-Partition -UseMaximumSize |
        Format-Volume -FileSystem FAT32 -Force

    # Store the list of drive letters before mounting the ISO image
    $DriveLettersBefore = (Get-Volume).Where({ $_.DriveLetter }).DriveLetter

    # Mount the ISO image
    Mount-DiskImage -ImagePath $ImagePath
    
    # Store the list of drive letters after mounting the ISO image
    $DriveLettersAfter = (Get-Volume).Where({ $_.DriveLetter }).DriveLetter

    # Determine the drive letter of the newly mounted ISO image
    $ISO = (Compare-Object -ReferenceObject $DriveLettersBefore -DifferenceObject $DriveLettersAfter).InputObject

    $bootPath     = Join-Path -Path $ISO -ChildPath 'boot'
    $bootsectPath = Join-Path -Path $bootPath -ChildPath 'bootsect.exe'
    
    # Update the boot sector on the USB drive
    Start-Process -FilePath $bootsectPath -ArgumentList "/nt60", "$($USBDrive.DriveLetter):" -Wait -NoNewWindow
    

    # Copy all files and directories from the ISO to the USB drive
    Copy-Item -Path "$ISO:\*" -Destination $($USBDrive.DriveLetter): -Recurse -Verbose
}
