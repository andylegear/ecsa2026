# verify-references.ps1
# Cross-checks citations in .tex files against entries in .bib file

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

Write-Host "`n=== Reference Verification Script ===" -ForegroundColor Cyan
Write-Host ""

# 1. Extract citation keys from all .tex files
Write-Host "Scanning .tex files for citations..." -ForegroundColor Yellow
$texFiles = Get-ChildItem -Path "." -Recurse -Include "*.tex" | Where-Object { $_.FullName -notmatch "sections_LONG|sources|Computer_Society" }
$citedKeys = @{}

foreach ($file in $texFiles) {
    $content = Get-Content $file.FullName -Raw
    # Match \cite{key}, \cite{key1,key2}, etc.
    $matches = [regex]::Matches($content, '\\cite\{([^}]+)\}')
    foreach ($match in $matches) {
        $keys = $match.Groups[1].Value -split ','
        foreach ($key in $keys) {
            $key = $key.Trim()
            if ($key -and $key -ne "") {
                if (-not $citedKeys.ContainsKey($key)) {
                    $citedKeys[$key] = @()
                }
                $citedKeys[$key] += $file.Name
            }
        }
    }
}

Write-Host "  Found $($citedKeys.Count) unique citation keys" -ForegroundColor Green

# 2. Extract bib entry keys from .bib file
Write-Host "`nScanning paper_references.bib for entries..." -ForegroundColor Yellow
$bibContent = Get-Content "paper_references.bib" -Raw
$bibMatches = [regex]::Matches($bibContent, '@\w+\{([^,]+),')
$bibKeys = @{}
$bibDois = @{}

foreach ($match in $bibMatches) {
    $key = $match.Groups[1].Value.Trim()
    if ($key -and $key -ne "" -and $key -notmatch "example:") {
        $bibKeys[$key] = $true
    }
}

# Extract DOIs
$doiMatches = [regex]::Matches($bibContent, '@\w+\{([^,]+),[\s\S]*?doi\s*=\s*\{([^}]+)\}', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
foreach ($match in $doiMatches) {
    $key = $match.Groups[1].Value.Trim()
    $doi = $match.Groups[2].Value.Trim()
    if ($key -and $doi) {
        $bibDois[$key] = $doi
    }
}

Write-Host "  Found $($bibKeys.Count) bib entries ($($bibDois.Count) with DOIs)" -ForegroundColor Green

# 3. Report undefined citations (in .tex but not in .bib)
Write-Host "`n=== Undefined Citations ===" -ForegroundColor Red
$undefined = $citedKeys.Keys | Where-Object { -not $bibKeys.ContainsKey($_) }
if ($undefined.Count -eq 0) {
    Write-Host "  None - all citations have matching bib entries" -ForegroundColor Green
} else {
    foreach ($key in $undefined | Sort-Object) {
        $files = ($citedKeys[$key] | Select-Object -Unique) -join ", "
        Write-Host "  [MISSING] $key (cited in: $files)" -ForegroundColor Red
    }
}

# 4. Report uncited bib entries
Write-Host "`n=== Uncited Bib Entries ===" -ForegroundColor Yellow
$uncited = $bibKeys.Keys | Where-Object { -not $citedKeys.ContainsKey($_) }
if ($uncited.Count -eq 0) {
    Write-Host "  None - all bib entries are cited" -ForegroundColor Green
} else {
    foreach ($key in $uncited | Sort-Object) {
        Write-Host "  [UNCITED] $key" -ForegroundColor Yellow
    }
}

# 5. List DOIs for verification
Write-Host "`n=== DOIs for Manual Verification ===" -ForegroundColor Cyan
Write-Host "(Copy to browser: https://doi.org/<DOI>)" -ForegroundColor DarkGray
Write-Host ""
foreach ($key in $bibDois.Keys | Sort-Object) {
    $doi = $bibDois[$key]
    Write-Host "  $key" -ForegroundColor White -NoNewline
    Write-Host " -> " -NoNewline
    Write-Host "https://doi.org/$doi" -ForegroundColor Blue
}

# 6. Summary
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "  Total citations in .tex: $($citedKeys.Count)"
Write-Host "  Total entries in .bib: $($bibKeys.Count)"
Write-Host "  Undefined citations: $($undefined.Count)" -ForegroundColor $(if ($undefined.Count -eq 0) { "Green" } else { "Red" })
Write-Host "  Uncited bib entries: $($uncited.Count)" -ForegroundColor $(if ($uncited.Count -eq 0) { "Green" } else { "Yellow" })
Write-Host "  Entries with DOIs: $($bibDois.Count)"
Write-Host ""

if ($undefined.Count -gt 0) {
    Write-Host "ERROR: Fix undefined citations before building!" -ForegroundColor Red
    exit 1
}

Write-Host "All citations verified. Run .\build.ps1 to compile." -ForegroundColor Green
