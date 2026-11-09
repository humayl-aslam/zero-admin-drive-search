$ErrorActionPreference = 'Stop'
$drive = "Z:"
$tempLog = "$env:TEMP\nightly_scan.txt"
$dummyDest = "$env:TEMP"
$tempOutput = "$drive\data.tmp.js"
$finalOutput = "$drive\data.js"

if (-not (Test-Path "$drive\")) { exit 0 }

# 1. Silent Robocopy scan across 427 GB drive
robocopy "$drive\" "$dummyDest" *.pdf *.docx *.pptx /L /S /NJH /NJS /FP /NC /NDL /XJ /R:0 /W:0 /UNILOG:$tempLog | Out-Null

if (-not (Test-Path $tempLog)) { exit 0 }

# Stream read log and stream write JSON to avoid OutOfMemoryException
$reader = [System.IO.File]::OpenText($tempLog)
$writer = [System.IO.StreamWriter]::new($tempOutput, $false, [System.Text.Encoding]::UTF8)
$writer.Write("window.data = [")

$first = $true
$count = 0

while (($line = $reader.ReadLine()) -ne $null) {
    $raw = $line.Trim()
    if ([string]::IsNullOrWhiteSpace($raw) -or $raw -match '\\(\.|\$|~\$)') { continue }

    $zIdx = $raw.IndexOf("Z:\", [System.StringComparison]::OrdinalIgnoreCase)
    if ($zIdx -lt 0) { continue }
    $cleanPath = $raw.Substring($zIdx).Trim()

    $lastSlash = $cleanPath.LastIndexOfAny([char[]]@('\', '/'))
    if ($lastSlash -lt 0) { continue }
    $name = $cleanPath.Substring($lastSlash + 1)
    
    $lastDot = $name.LastIndexOf('.')
    if ($lastDot -lt 0) { continue }
    $ext = $name.Substring($lastDot + 1).ToUpper()
    
    if (-not ($ext -in @('PDF','DOCX','PPTX'))) { continue }

    # Clean whitespace and escape quotes/backslashes for valid JSON
    $safeName = ($name -replace "[\r\n\t]+", " ").Replace('\', '\\').Replace('"', '\"')
    $cleanPathCleaned = ($cleanPath -replace "[\r\n\t]+", " ")
    $safeWin = $cleanPathCleaned.Replace('\', '\\').Replace('"', '\"')
    $safePosix = $cleanPathCleaned.Replace('\', '/').Replace('"', '\"')

    $record = "{`"N`":`"$safeName`",`"P`":`"$safePosix`",`"W`":`"$safeWin`",`"E`":`"$ext`"}"

    if (-not $first) {
        $writer.Write("," + $record)
    } else {
        $writer.Write($record)
        $first = $false
    }
    $count++
}

$reader.Close()
$writer.Write("];")
$writer.Flush()
$writer.Close()

Remove-Item $tempLog -Force -ErrorAction SilentlyContinue

# 2. Safety Check: Only overwrite if we found at least 1,000 files
if ((Test-Path $tempOutput) -and ($count -gt 1000)) {
    Move-Item -Path $tempOutput -Destination $finalOutput -Force
} else {
    Remove-Item $tempOutput -Force -ErrorAction SilentlyContinue
}