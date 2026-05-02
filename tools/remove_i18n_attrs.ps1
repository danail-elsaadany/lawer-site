$files = Get-ChildItem -Path . -Recurse -Filter *.html | Where-Object { $_.FullName -notmatch '\\node_modules\\' }
foreach ($f in $files) {
    $c = Get-Content $f.FullName -Raw
    $newC = $c -replace '(?i)\s*data-en="[^"]*"', '' -replace '(?i)\s*data-ar="[^"]*"', ''
    if ($c -ne $newC) {
        Set-Content $f.FullName $newC -Encoding UTF8
    }
}
Write-Host "Removed data-en and data-ar."
