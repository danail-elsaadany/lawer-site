param(
    [string]$InputFile,
    [string]$OutputDir
)

$content = Get-Content -Path $InputFile -Raw -Encoding UTF8
# The format looks like:
# 1-
#  قانون الشركات والأعمال
# or
# 2
# التقاضي وتسوية المنازعات

$lines = $content -split "`n"
$services = @()

$i = 0
while ($i -lt $lines.Length) {
    $line = $lines[$i].Trim()
    if ($line -match "^(\d+)-?$") {
        # The next line should be the title
        $i++
        while ($i -lt $lines.Length -and [string]::IsNullOrWhiteSpace($lines[$i].Trim())) {
            $i++
        }
        if ($i -lt $lines.Length) {
            $title = $lines[$i].Trim()
            if ($title -ne "") {
                $services += [PSCustomObject]@{
                    Number = $matches[1]
                    Title = $title
                }
            }
        }
    }
    $i++
}

# Output to a JSON file for easy processing if needed, or structured text
$outPath = Join-Path $OutputDir "services_list.json"
$services | ConvertTo-Json -EnumsAsStrings | Set-Content $outPath -Encoding UTF8
Write-Host "Found $($services.Count) services. Extracted to services_list.json"
