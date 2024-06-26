Function Get-AutoCADLanguagePack {

    $TempPath = "C:\Temp\Autodesk"
    if(-not(Test-Path -Path $TempPath -PathType Container)) { 
        New-Item -Path $TempPath -ItemType Directory -Force > $null
    }
    
    $LanguagePackData = @{
        "AutoCAD" = @{
            '2019' = @{
                "English" = "https://knowledge.autodesk.com/sites/default/files/file_downloads/AutoCAD_2019_English_LP_Win_64bit_dlm.sfx.exe"
                "German"  = "http://download.autodesk.com/us/support/files/autocad_2019_language_packs/AutoCAD_2019_German_LP_Win_64bit_dlm.sfx.exe"
                "Italian" = "http://download.autodesk.com/us/support/files/autocad_2019_language_packs/AutoCAD_2019_Italian_LP_Win_64bit_dlm.sfx.exe"
                "Polish"  = "http://download.autodesk.com/us/support/files/autocad_2019_language_packs/AutoCAD_2019_Polish_LP_Win_64bit_dlm.sfx.exe"
                "Spanish" = "http://download.autodesk.com/us/support/files/autocad_2019_language_packs/AutoCAD_2019_Spanish_LP_Win_64bit_dlm.sfx.exe"
                "French"  = "http://download.autodesk.com/us/support/files/autocad_2019_language_packs/AutoCAD_2019_French_LP_Win_64bit_dlm.sfx.exe"
                "Portuguese" = "http://download.autodesk.com/us/support/files/autocad_2019_language_packs/AutoCAD_2019_Brazilian_Portuguese_LP_Win_64bit_dlm.sfx.exe"
            }
            '2020' = @{
                "English" = "http://download.autodesk.com/us/support/autocad_2020_language_packs/autocad_2020_english_lp_win_64bit_dlm.sfx.exe"
                "German"  = "http://download.autodesk.com/us/support/autocad_2020_language_packs/autocad_2020_german_lp_win_64bit_dlm.sfx.exe"
                "Italian" = "http://download.autodesk.com/us/support/autocad_2020_language_packs/autocad_2020_italian_lp_win_64bit_dlm.sfx.exe"
                "Polish"  = "http://download.autodesk.com/us/support/autocad_2020_language_packs/autocad_2020_polish_lp_win_64bit_dlm.sfx.exe"
                "Spanish" = "http://download.autodesk.com/us/support/autocad_2020_language_packs/autocad_2020_spanish_lp_win_64bit_dlm.sfx.exe"
                "French"  = "http://download.autodesk.com/us/support/autocad_2020_language_packs/autocad_2020_french_lp_win_64bit_dlm.sfx.exe"
                "Portuguese" = "http://download.autodesk.com/us/support/autocad_2020_language_packs/autocad_2020_brazilian_portuguese_lp_win_64bit_dlm.sfx.exe"
            }
            '2021' = @{
                "English" = "http://download.autodesk.com/us/support/autocad_2021_language_packs/autocad_2021_english_lp_win_64bit_dlm.sfx.exe"
                "German"  = "http://download.autodesk.com/us/support/autocad_2021_language_packs/autocad_2021_german_lp_win_64bit_dlm.sfx.exe"
                "Italian" = "http://download.autodesk.com/us/support/autocad_2021_language_packs/autocad_2021_italian_lp_win_64bit_dlm.sfx.exe"
                "Polish"  = "http://download.autodesk.com/us/support/autocad_2021_language_packs/autocad_2021_polish_lp_win_64bit_dlm.sfx.exe"
                "Spanish" = "http://download.autodesk.com/us/support/autocad_2021_language_packs/autocad_2021_spanish_lp_win_64bit_dlm.sfx.exe"
                "French"  = "http://download.autodesk.com/us/support/autocad_2021_language_packs/autocad_2021_french_lp_win_64bit_dlm.sfx.exe"
                "Portuguese" = "http://download.autodesk.com/us/support/autocad_2021_language_packs/autocad_2021_brazilian_portuguese_lp_win_64bit_dlm.sfx.exe"
            }
            '2022' = @{
                "English" = "https://up.autodesk.com/2022/ACD/FF6CDC8A-8CA0-389E-A191-8A983D7FE689/Autodesk_AutoCAD_2022_English_Language_Pack.exe"
                "German"  = "https://up.autodesk.com/2022/ACD/1C83E4D4-77A2-3892-AC87-FBE013CC5200/Autodesk_AutoCAD_2022_German_Language_Pack.exe"
                "Italian" = "https://up.autodesk.com/2022/ACD/DF72B8F7-16D2-3318-8E76-5BCEE8161282/Autodesk_AutoCAD_2022_Italian_Language_Pack.exe"
                "Polish"  = "https://up.autodesk.com/2022/ACD/19B198D1-294B-3ACE-9743-761F00F8B403/Autodesk_AutoCAD_2022_Polish_Language_Pack.exe"
                "Spanish" = "https://up.autodesk.com/2022/ACD/8AD46E14-3E64-3A8F-9C2E-6BC889A00783/Autodesk_AutoCAD_2022_Spanish_Language_Pack.exe"
                "French"  = "https://up.autodesk.com/2022/ACD/A8B4F225-35C0-3995-ACF5-C18835B4761E/Autodesk_AutoCAD_2022_French_Language_Pack.exe"
                "Portuguese" = "https://up.autodesk.com/2022/ACD/7BE73380-1F56-3EDF-ADC6-830A1705E0B7/Autodesk_AutoCAD_2022_Brazilian_Portuguese_Language_Pack.exe"
            }
        }
        "AutoCAD_Architecture" = @{
            '2019' = @{
                "English" = "http://download.autodesk.com/us/support/files/autocad_architecture_2019_language_packs/AutoCAD_Architecture_2019_English_LP_Win_64bit_dlm.sfx.exe"
                "German"  = "http://download.autodesk.com/us/support/files/autocad_architecture_2019_language_packs/AutoCAD_Architecture_2019_German_LP_Win_64bit_dlm.sfx.exe"
                "Italian" = "http://download.autodesk.com/us/support/files/autocad_architecture_2019_language_packs/AutoCAD_Architecture_2019_Italian_LP_Win_64bit_dlm.sfx.exe"
                "Polish"  = "http://download.autodesk.com/us/support/files/autocad_architecture_2019_language_packs/AutoCAD_Architecture_2019_Polish_LP_Win_64bit_dlm.sfx.exe"
                "Spanish" = "http://download.autodesk.com/us/support/files/autocad_architecture_2019_language_packs/AutoCAD_Architecture_2019_Spanish_LP_Win_64bit_dlm.sfx.exe"
                "French"  = "http://download.autodesk.com/us/support/files/autocad_architecture_2019_language_packs/AutoCAD_Architecture_2019_French_LP_Win_64bit_dlm.sfx.exe"
            }
            '2020' = @{
                "English" = "http://download.autodesk.com/us/support/autocad_architecture_2020_language_packs/autocad_architecture_2020_english_lp_win_64bit_dlm.sfx.exe"
                "German"  = "http://download.autodesk.com/us/support/autocad_architecture_2020_language_packs/autocad_architecture_2020_german_lp_win_64bit_dlm.sfx.exe"
                "Italian" = "http://download.autodesk.com/us/support/autocad_architecture_2020_language_packs/autocad_architecture_2020_italian_lp_win_64bit_dlm.sfx.exe"
                "Polish"  = "http://download.autodesk.com/us/support/autocad_architecture_2020_language_packs/autocad_architecture_2020_polish_lp_win_64bit_dlm.sfx.exe"
                "Spanish" = "http://download.autodesk.com/us/support/autocad_architecture_2020_language_packs/autocad_architecture_2020_spanish_lp_win_64bit_dlm.sfx.exe"
                "French"  = "http://download.autodesk.com/us/support/autocad_architecture_2020_language_packs/autocad_architecture_2020_french_lp_win_64bit_dlm.sfx.exe"
            }
            '2021' = @{
                "English" = "http://download.autodesk.com/us/support/autocad_architecture_2021_language_packs/autocad_architecture_2021_english_lp_win_64bit_dlm.sfx.exe"
                "German"  = "http://download.autodesk.com/us/support/autocad_architecture_2021_language_packs/autocad_architecture_2021_german_lp_win_64bit_dlm.sfx.exe"
                "Italian" = "http://download.autodesk.com/us/support/autocad_architecture_2021_language_packs/autocad_architecture_2021_italian_lp_win_64bit_dlm.sfx.exe"
                "Polish"  = "http://download.autodesk.com/us/support/autocad_architecture_2021_language_packs/autocad_architecture_2021_polish_lp_win_64bit_dlm.sfx.exe"
                "Spanish" = "http://download.autodesk.com/us/support/autocad_architecture_2021_language_packs/autocad_architecture_2021_spanish_lp_win_64bit_dlm.sfx.exe"
                "French"  = "http://download.autodesk.com/us/support/autocad_architecture_2021_language_packs/autocad_architecture_2021_french_lp_win_64bit_dlm.sfx.exe"
            }
            '2022' = @{
                "English" = "https://up.autodesk.com/2022/ARCHDESK/C08602E3-A05E-3336-B8C8-8F2ECDA1B676/Autodesk_AutoCAD_Architecture_2022_English_Language_Pack.exe"
                "German"  = "https://up.autodesk.com/2022/ARCHDESK/06E2AB6D-C467-39C1-A0E3-DA7180F08973/Autodesk_AutoCAD_Architecture_2022_German_Language_Pack.exe"
                "Italian" = "https://up.autodesk.com/2022/ARCHDESK/2B43806D-C2EB-396C-9B90-8615FFBD7FB0/Autodesk_AutoCAD_Architecture_2022_Italian_Language_Pack.exe"
                "Polish"  = "https://up.autodesk.com/2022/ARCHDESK/A38A2FF6-FAFB-3F39-8744-38C32446EAE7/Autodesk_AutoCAD_Architecture_2022_Polish_Language_Pack.exe"
                "Spanish" = "https://up.autodesk.com/2022/ARCHDESK/B72558E5-FBC8-3585-B56A-5BD6346734C6/Autodesk_AutoCAD_Architecture_2022_Spanish_Language_Pack.exe"
                "French"  = "https://up.autodesk.com/2022/ARCHDESK/1A4DA4C1-F27D-384F-9300-039BD39233BE/Autodesk_AutoCAD_Architecture_2022_French_Language_Pack.exe"
            }
        }
    }
    $ProductData = ($LanguagePackData.Keys | Out-GridView -Title "Select Product" -OutputMode Single)

    $VersionData = if ($ProductData) { 
        $LanguagePackData[$ProductData].Keys | Out-GridView -Title "Select Version" -OutputMode Single
    }

    $LanguageData = if ($VersionData) { 
        $LanguagePackData[$ProductData][$VersionData] | Out-GridView -Title "Select Language" -OutputMode Multiple
    }
    
    $WebClient = New-Object System.Net.WebClient
    foreach ($language in $LanguageData) {
        
        $Message = "{0} {1} - {2} Language Pack" -f $ProductData, $VersionData, $language.Name
        $DestinationPath = Join-Path -Path $TempPath -ChildPath ($ProductData, $VersionData, $language.Name, ".exe" -join "_")
    
        try {
            Write-Host "Downloading:`t$Message"
            $WebClient.DownloadFile($language.Value, $DestinationPath)
    
            Write-Host "Installing:`t$Message"
            Start-Process -FilePath $DestinationPath -Wait -ErrorAction Stop
        } catch {
            Write-Host "Error during $Message deployment" -ForegroundColor Yellow
        }
    }
    $WebClient.Dispose()
}
# Example usage
# Get-AutoCADLanguagePack
