Get-ChildItem -Path . -Recurse -Filter *.html | ForEach-Object {

    $content = Get-Content $_.FullName -Raw -Encoding UTF8

    $content = $content -replace '\+971564668807','<a href="tel:+971564668807">+971564668807</a>'

    Set-Content $_.FullName $content -Encoding UTF8

    Write-Host "Updated:" $_.FullName
}