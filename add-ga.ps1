$gaCode = @"

<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-07NRXF8PB8"></script>
<script>
window.dataLayer = window.dataLayer || [];
function gtag(){dataLayer.push(arguments);}
gtag('js', new Date());
gtag('config', 'G-07NRXF8PB8');
</script>

"@

Get-ChildItem -Path . -Recurse -Filter *.html | ForEach-Object {

    $content = Get-Content $_.FullName -Raw

    if ($content -notmatch "G-07NRXF8PB8") {

        $content = $content -replace "</head>", "$gaCode`r`n</head>"

        Set-Content $_.FullName $content -Encoding UTF8

        Write-Host "Updated:" $_.FullName
    }

}