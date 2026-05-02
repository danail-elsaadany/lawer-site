$indexContent = [System.IO.File]::ReadAllText("$PWD\index.html", [System.Text.Encoding]::UTF8)
$headerRegex = [regex]::new('(?s)<header class="main-header">.*?</header>')
$match = $headerRegex.Match($indexContent)
if (-not $match.Success) {
    Write-Host "Header not found"
    exit
}
$newHeader = $match.Value

function Adjust-HeaderForServices {
    param([string]$header)
    $h = $header
    $pages = @("index.html", "about.html", "team.html", "services.html", 
               "articles.html", "notary.html", "private-notary.html", 
               "legal-drafting.html", "trademark.html", "trademark-monitoring.html", 
               "trademark-search.html", "global-partners.html", "media-center.html", 
               "internal-training.html", "terms.html", "contact.html")
    foreach ($page in $pages) {
        $h = $h.Replace("href=`"$page`"", "href=`"../$page`"")
    }
    $h = $h.Replace('src="assets/', 'src="../assets/')
    $h = $h.Replace("href='services/", "href='../services/")
    return $h
}

$anyHeaderRegex = [regex]::new('(?s)<header.*?>.*?</header>')

Get-ChildItem -Path . -Recurse -Filter *.html | ForEach-Object {
    $path = $_.FullName
    $content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    
    $headerToInject = $newHeader
    if ($path -match '\\(services|assets)\\') {
        $headerToInject = Adjust-HeaderForServices -header $newHeader
    }
    
    $matchAny = $anyHeaderRegex.Match($content)
    if ($matchAny.Success) {
        $before = $content.Substring(0, $matchAny.Index)
        $after = $content.Substring($matchAny.Index + $matchAny.Length)
        $newContent = $before + $headerToInject + $after
        
        if ($newContent -cne $content) {
            [System.IO.File]::WriteAllText($path, $newContent, [System.Text.Encoding]::UTF8)
            Write-Host "Updated $($path)"
        }
    }
}
Write-Host "Done"
