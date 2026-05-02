param(
    [string]$InputFile,
    [string]$TemplateFile,
    [string]$LinksFile,
    [string]$OutputDir
)

$content = Get-Content -Path $InputFile -Raw -Encoding UTF8
$template = Get-Content -Path $TemplateFile -Raw -Encoding UTF8
$links = Get-Content -Path $LinksFile -Raw -Encoding UTF8

$dropdownTemplate = $template.Replace("__DROPDOWN_LINKS__", $links)

$lines = $content -split "`n"
$serviceNum = 1
$i = 0

while ($i -lt $lines.Length) {
    $line = $lines[$i].Trim()
    if ($line -match "^(\d+)-?$") {
        $i++
        while ($i -lt $lines.Length -and [string]::IsNullOrWhiteSpace($lines[$i].Trim())) {
            $i++
        }
        if ($i -lt $lines.Length) {
            $title = $lines[$i].Trim()
            $i++
            
            # Now gather the content paragraphs until the next number
            $serviceContent = ""
            while ($i -lt $lines.Length) {
                $checkLine = $lines[$i].Trim()
                if ($checkLine -match "^(\d+)-?$") {
                    break
                }
                if (-not [string]::IsNullOrWhiteSpace($checkLine)) {
                    if ($checkLine -match "^-") {
                         $serviceContent += "<li>$($checkLine.TrimStart('-').Trim())</li>`n"
                    } elseif ($checkLine -match "^المزيد" -or $checkLine -match "اضغط على المزيد") {
                        # Ignore "More" button text
                    } else {
                        $serviceContent += "<p>$checkLine</p>`n"
                    }
                }
                $i++
            }
            
            # Wrap li in ul
            if ($serviceContent -match "<li>") {
                $serviceContent = $serviceContent -replace "(?s)(<li>.*?</li>)", "<ul>`$1</ul>"
                # This is a basic wrapper, might wrap each individually, but CSS will handle it or we can just leave it as p/li mix.
            }
            
            $finalHtml = $dropdownTemplate.Replace("__TITLE__", $title).Replace("__CONTENT__", $serviceContent)
            $outPath = Join-Path $OutputDir "service-$serviceNum.html"
            Set-Content -Path $outPath -Value $finalHtml -Encoding UTF8
            Write-Host "Generated service-$serviceNum.html"
            $serviceNum++
            continue # Already incremented $i to the next number
        }
    }
    $i++
}
Write-Host "Done generating pages."
