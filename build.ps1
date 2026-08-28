# Build script for samplepaper.tex
# Run with: .\build.ps1

$ErrorActionPreference = "Continue"

Write-Host "Building samplepaper.pdf..." -ForegroundColor Cyan

# First pdflatex pass
Write-Host "`n[1/4] Running pdflatex (first pass)..." -ForegroundColor Yellow
pdflatex -interaction=nonstopmode samplepaper.tex | Out-Null

# Run bibtex for bibliography
Write-Host "[2/4] Running bibtex..." -ForegroundColor Yellow
bibtex samplepaper | Out-Null

# Second pdflatex pass (resolve references)
Write-Host "[3/4] Running pdflatex (second pass)..." -ForegroundColor Yellow
pdflatex -interaction=nonstopmode samplepaper.tex | Out-Null

# Third pdflatex pass (finalize)
Write-Host "[4/4] Running pdflatex (final pass)..." -ForegroundColor Yellow
pdflatex -interaction=nonstopmode samplepaper.tex

# Check result
if (Test-Path "samplepaper.pdf") {
    $pdf = Get-Item "samplepaper.pdf"
    $pages = (Get-Content "samplepaper.log" | Select-String "Output written on samplepaper.pdf \((\d+) pages" | ForEach-Object { $_.Matches.Groups[1].Value })
    Write-Host "`nBuild complete!" -ForegroundColor Green
    Write-Host "Output: samplepaper.pdf ($pages pages, $([math]::Round($pdf.Length/1KB)) KB)" -ForegroundColor Green
} else {
    Write-Host "`nBuild failed - check samplepaper.log for errors" -ForegroundColor Red
}
