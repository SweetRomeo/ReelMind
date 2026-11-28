param([string]$OutputDirectory = 'build/reel-voice')

$ErrorActionPreference = 'Stop'
$outDir = (New-Item -ItemType Directory -Force -Path $OutputDirectory).FullName
$lessons = Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'reel_narration.json') | ConvertFrom-Json
$speaker = New-Object -ComObject SAPI.SpVoice

function Get-ReelVoice([string]$language) {
    $localeId = [cultureinfo]::GetCultureInfo($language).LCID
    foreach ($key in 'Speech', 'Speech_OneCore') {
        $path = "SOFTWARE\Microsoft\$key\Voices\Tokens"
        foreach ($token in Get-ChildItem -LiteralPath "HKLM:\$path" -ErrorAction SilentlyContinue) {
            $voice = New-Object -ComObject SAPI.SpObjectToken
            $voice.SetId($token.Name)
            foreach ($code in $voice.GetAttribute('Language') -split ';') {
                if ([Convert]::ToInt32($code, 16) -eq $localeId) {
                    return $voice
                }
            }
        }
    }
    throw "Install a Windows text-to-speech voice for $language."
}

foreach ($language in 'tr', 'en') {
    $culture = @{ tr = 'tr-TR'; en = 'en-US' }[$language]
    $apiPronunciation = @{ tr = 'ey pi ay'; en = 'A P I' }[$language]
    $speaker.Voice = Get-ReelVoice $culture
    Write-Output $speaker.Voice.GetDescription()
    foreach ($lesson in $lessons.PSObject.Properties) {
        for ($index = 0; $index -lt $lesson.Value.Count; $index++) {
            $file = Join-Path $outDir "$($lesson.Name)_${language}_$index.wav"
            $stream = New-Object -ComObject SAPI.SpFileStream
            $stream.Open($file, 3)
            try {
                $speaker.AudioOutputStream = $stream
                $spokenLine = $lesson.Value[$index].$language -creplace '\bAPI\b', $apiPronunciation
                [void]$speaker.Speak($spokenLine)
            } finally {
                $stream.Close()
            }
        }
    }
}
