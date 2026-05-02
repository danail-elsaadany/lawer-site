param(
    [string]$TemplateFile,
    [string]$LinksFile,
    [string]$OutputDir
)

$template = Get-Content -Path $TemplateFile -Raw -Encoding UTF8
$links = Get-Content -Path $LinksFile -Raw -Encoding UTF8

# Since these are root pages, fix the paths
$baseTemplate = $template.Replace("__DROPDOWN_LINKS__", $links).Replace("../", "")

$pagesMap = @{
    "about.html" = @{File = "من نحن.txt"; Title = "من نحن"};
    "team.html" = @{File = "فريق المحامين لمكتب المحاماة.txt"; Title = "فريق المحامين"};
    "notary.html" = @{File = "صفحة خدمات التصديق.txt"; Title = "خدمات التصديق"};
    "legal-drafting.html" = @{File = "الصياغة القانونية .txt"; Title = "الصياغة القانونية"};
    "trademark.html" = @{File = "العلامة    التجارية.txt"; Title = "العلامة التجارية"};
    "trademark-monitoring.html" = @{File = "مراقبة العلامة التجارية.txt"; Title = "مراقبة العلامة التجارية"};
    "global-partners.html" = @{File = "الشركاء العالمين.txt"; Title = "الشركاء العالميين"};
    "media-center.html" = @{File = "المركز الاعلامى .txt"; Title = "المركز الاعلامى"};
    "internal-training.html" = @{File = "برنامج التدريب الداخلى .txt"; Title = "برنامج التدريب الداخلي"};
    "articles.html" = @{File = "مقال رقم 1 للمدونة القانونية.txt"; Title = "المقالات والمدونات القانونية"};
    "terms.html" = @{File = "الشروط والاحكام.txt"; Title = "الشروط والاحكام"};
    "contact.html" = @{File = "اتصل بنا .txt"; Title = "تواصل معنا"};
    "private-notary.html" = @{File = ""; Title = "كاتب العدل الخاص"}
}

foreach ($page in $pagesMap.GetEnumerator()) {
    $outFile = $page.Name
    $info = $page.Value
    
    $contentHtml = ""
    if ($info.File -and (Test-Path $info.File)) {
        $rawTxt = Get-Content -Path $info.File -Raw -Encoding UTF8
        $lines = $rawTxt -split "`n"
        foreach ($line in $lines) {
            $t = $line.Trim()
            if ($t) {
                # Simple markdown-like
                if ($t -match "^-") {
                    $contentHtml += "<li>$($t.TrimStart('-').Trim())</li>`n"
                } else {
                    $contentHtml += "<p>$t</p>`n"
                }
            }
        }
        if ($contentHtml -match "<li>") {
            $contentHtml = $contentHtml -replace "(?s)(<li>.*?</li>)", "<ul>`$1</ul>"
        }
    } else {
        $contentHtml = "<p>محتوى الصفحة قيد التحديث...</p>"
    }
    
    $finalHtml = $baseTemplate.Replace("__TITLE__", $info.Title).Replace("__CONTENT__", $contentHtml)
    $outPath = Join-Path $OutputDir $outFile
    Set-Content -Path $outPath -Value $finalHtml -Encoding UTF8
    Write-Host "Generated $outFile"
}
Write-Host "All remaining pages generated."
