$ErrorActionPreference = "SilentlyContinue"

function Get-Signature {

    [CmdletBinding()]
    param (
        [string[]]$FilePath
    )

    $Existence = Test-Path -PathType "Leaf" -Path $FilePath
    $Authenticode = (Get-AuthenticodeSignature -FilePath $FilePath -ErrorAction SilentlyContinue).Status
    $Signature = "Invalid Signature (UnknownError)"

    if ($Existence) {
        if ($Authenticode -eq "Valid") {
            $Signature = "Ervenyes Alairas"
        }
        elseif ($Authenticode -eq "NotSigned") {
            $Signature = "Ervenytelen Alairas (NotSigned)"
        }
        elseif ($Authenticode -eq "HashMismatch") {
            $Signature = "Ervenytelen Alairas (HashMismatch)"
        }
        elseif ($Authenticode -eq "NotTrusted") {
            $Signature = "Ervenytelen Alairas (NotTrusted)"
        }
        elseif ($Authenticode -eq "UnknownError") {
            $Signature = "Ervenytelen Alairas (UnknownError)"
        }
        return $Signature
    } else {
        $Signature = "Fajl nem talalhato"
        return $Signature
    }
}

Clear-Host

Write-Host "";
Write-Host "";
Write-Host -ForegroundColor Green " ________  ___       ________      ___    ___ ________  ___       ________  ________           ________   ________      ";
Write-Host -ForegroundColor Green "|\   __  \|\  \     |\   __  \    |\  \  /  /|\   ____\|\  \     |\   __  \|\   ___  \        |\   ____\ |\   ____\     ";
Write-Host -ForegroundColor Green "\ \  \|\  \ \  \    \ \  \|\  \   \ \  \/  / | \  \___|\ \  \    \ \  \|\  \ \  \\ \  \       \ \  \___|_\ \  \___|_    ";
Write-Host -ForegroundColor Green " \ \   ____\ \  \    \ \   __  \   \ \    / / \ \  \    \ \  \    \ \   __  \ \  \\ \  \       \ \_____  \\ \_____  \   ";
Write-Host -ForegroundColor Green "  \ \  \___|\ \  \____\ \  \ \  \   \/  /  /   \ \  \____\ \  \____\ \  \ \  \ \  \\ \  \       \|____|\  \\|____|\  \  ";
Write-Host -ForegroundColor Green "   \ \__\    \ \_______\ \__\ \__\__/  / /      \ \_______\ \_______\ \__\ \__\ \__\\ \__\        ____\_\  \ ____\_\  \ ";
Write-Host -ForegroundColor Green "    \|__|     \|_______|\|__|\|__|\___/ /        \|_______|\|_______|\|__|\|__|\|__| \|__|       |\_________\\_________\";
Write-Host -ForegroundColor Green "                                 \|___|/                                                         \|_________\|_________|";
Write-Host "";
Write-Host -ForegroundColor Blue "Made by: PlayClan - " -NoNewLine
Write-Host -ForegroundColor Red "dc.playclan.hu"
Write-Host "";

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if (!(Test-Admin)) {
    Write-Warning "Kerem futtassa ezt a scriptet adminisztratorkent."
    Start-Sleep 10
    Exit
}

$sw = [Diagnostics.Stopwatch]::StartNew()

if (!(Get-PSDrive -Name HKLM -PSProvider Registry)) {
    Try {
        New-PSDrive -Name HKLM -PSProvider Registry -Root HKEY_LOCAL_MACHINE
    }
    Catch {
        Write-Warning "Hiba a HKEY_Local_Machine csatlakoztatasakor"
    }
}

$bv = ("bam", "bam\State")
Try {
    $Users = foreach($ii in $bv) {
        Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$($ii)\UserSettings\" | Select-Object -ExpandProperty PSChildName
    }
}
Catch {
    Write-Warning "Hiba a BAM kulcs elemzeseben. Valoszinu nem tamogatott Windows verzio"
    Exit
}

$rpath = @("HKLM:\SYSTEM\CurrentControlSet\Services\bam\", "HKLM:\SYSTEM\CurrentControlSet\Services\bam\state\")

$UserTime = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation").TimeZoneKeyName
$UserBias = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation").ActiveTimeBias
$UserDay = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation").DaylightBias

$Bam = Foreach ($Sid in $Users) {
    $u++
    foreach($rp in $rpath) {
        $BamItems = Get-Item -Path "$($rp)UserSettings\$Sid" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property
        Write-Host -ForegroundColor Red "Kicsomagolas " -NoNewLine
        Write-Host -ForegroundColor Blue "$($rp)UserSettings\$SID"
        $bi = 0

        Try {
            $objSID = New-Object System.Security.Principal.SecurityIdentifier($Sid)
            $User = $objSID.Translate([System.Security.Principal.NTAccount])
            $User = $User.Value
        }
        Catch { $User = "" }
        $i = 0
        ForEach ($Item in $BamItems) {
            $i++
            $Key = Get-ItemProperty -Path "$($rp)UserSettings\$Sid" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $Item

            If ($key.length -eq 24) {
                $Hex = [System.BitConverter]::ToString($key[7..0]) -replace "-", ""
                $TimeLocal = Get-Date ([DateTime]::FromFileTime([Convert]::ToInt64($Hex, 16))) -Format "yyyy-MM-dd HH:mm:ss"
                $TimeUTC = Get-Date ([DateTime]::FromFileTimeUtc([Convert]::ToInt64($Hex, 16))) -Format "yyyy-MM-dd HH:mm:ss"
                $Bias = -([convert]::ToInt32([Convert]::ToString($UserBias, 2), 2))
                $Day = -([convert]::ToInt32([Convert]::ToString($UserDay, 2), 2)) 
                $Biasd = $Bias / 60
                $Dayd = $Day / 60
                $TimeUser = (Get-Date ([DateTime]::FromFileTimeUtc([Convert]::ToInt64($Hex, 16))).addminutes($Bias) -Format "yyyy-MM-dd HH:mm:ss") 
                $d = if((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3) -match '\d{1}') {
                    ((split-path -path $item).Remove(23)).trimstart("\Device\HarddiskVolume")
                } else { $d = "" }
                $f = if((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3) -match '\d{1}') {
                    Split-path -leaf ($item).TrimStart()
                } else { $item }	
                $cp = if((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3) -match '\d{1}') {
                    ($item).Remove(1, 23)
                } else { $cp = "" }
                $path = if((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3) -match '\d{1}') {
                    Join-Path -Path "C:" -ChildPath $cp
                } else { $path = "" }			
                $sig = if((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3) -match '\d{1}') {
                    Get-Signature -FilePath $path
                } else { $sig = "" }				
                [PSCustomObject]@{
                    'Execution Time' = $TimeLocal
                    'Last Run Time (UTC)' = $TimeUTC
                    'Last Run User Time' = $TimeUser
                    'Application' = $f
                    'Path' = $path 
                    'Signature' = $Sig
                    'User' = $User
                    'SID' = $Sid
                    'Regpath' = $rp
                }
            }
        }
    }
}

$Bam | Out-GridView -PassThru -Title "BAM kulcs bejegyzesek $($Bam.count)  - Felhasznalo Idozona: ($UserTime) -> Aktiv Eltolas: ($Bias) - Nyari Idotartam: ($Day)"

$sw.stop()
$t = $sw.Elapsed.TotalMinutes
Write-Host ""
Write-Host "Eltelt ido $t perc" -ForegroundColor Yellow