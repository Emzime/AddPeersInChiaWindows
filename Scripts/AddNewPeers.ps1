Function PrintMsg {
    Param (
        [Parameter(Mandatory=$true)]   [String]$msg,
        [Parameter(Mandatory=$false)]  [String]$backColor = "black",
        [Parameter(Mandatory=$false)]  [String]$sharpColor = "Red",
        [Parameter(Mandatory=$false)]  [String]$textColor = "Green"
    )
    
    # Condition
    $charCount = ($msg.Length + 2)

    # Count number of #
    for ($i = 1 ; $i -le $charCount ; $i++){$sharp += "#"}

    # Display message
    Write-Host ("`n$($sharp)") -ForegroundColor $sharpColor -BackgroundColor $BackColor
    Write-Host (" $($msg) ") -ForegroundColor $textColor -BackgroundColor $BackColor
    Write-Host ("$($sharp)`n") -ForegroundColor $sharpColor -BackgroundColor $BackColor
}
# Search for the name of the script
$scriptDir = Split-Path -parent $MyInvocation.MyCommand.Path

# Unblock file
Unblock-File -Path $scriptDir

# Intenationalization import
$lang = Import-LocalizedData -BaseDirectory "$scriptDir\Lang"

# Take a break
$timeWait = 600

# Convert to minutes
$Minutes = $timeWait / 60

# Define $timeout
$timeout = new-timespan -Minutes $Minutes
$sw = [diagnostics.stopwatch]::StartNew()

# Check if chia is launched
if(!(Get-Process -NAME "chia" -erroraction "silentlycontinue"))
{
    # Message
    PrintMsg -msg $lang.NotRun -textColor "Red" -backColor "Black" -sharpColor "Red"
    PrintMsg -msg $lang.ClickToExit -textColor "Red" -backColor "Black" -sharpColor "Red"
    exit
}

while ($sw.elapsed -lt $timeout)
{
    # Link to website
    $url = Invoke-RestMethod -Uri "https://chia.keva.app/"

    # Defines the characters to be found
    $IPv4RegexNew = '((?:(?:1\d\d|2[0-5][0-5]|2[0-4]\d|0?[1-9]\d|0?0?\d)\.){3}(?:1\d\d|2[0-5][0-5]|2[0-4]\d|0?[1-9]\d|0?0?\d))'

    # Fichier log
    $fileLog = "$scriptDir\..\Keva.log"

    # Launch search and create file
    $peers = [regex]::Matches($url, $IPv4RegexNew) | %{$_.Groups[1].Value + ":8444"} | tee "$fileLog"

    # Title
    PrintMsg -msg $lang.Connect

    # Open ip file
    [System.IO.StreamReader]$sr = [System.IO.File]::Open("$fileLog", [System.IO.FileMode]::Open)
    while (-not $sr.EndOfStream)
    {
        $line = $sr.ReadLine()
        cd $env:localAPPDATA\Chia-Blockchain\app-*.*.*\resources\app.asar.unpacked\daemon\
        .\chia.exe show -a "$line"
        Start-Sleep -s 5

        # supprime le fichier
        $removeFile = Remove-Item "$fileLog"

        # Title
        PrintMsg -msg "$($lang.Stop) $timeWait $($lang.Min)"

        # Take a break
        start-sleep -seconds $timeWait

        # Run script
        ."$scriptDir\AddNewPeers.ps1"
    }
    $sr.Close()
}