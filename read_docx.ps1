param (
    [string]$FolderPath
)

$files = Get-ChildItem -Path $FolderPath -Filter "*.docx"
foreach ($file in $files) {
    Write-Host "--- CONTENT OF $($file.Name) ---"
    $tempZip = Join-Path $FolderPath "_temp.zip"
    $tempDir = Join-Path $FolderPath "_tempdir"
    
    Copy-Item $file.FullName -Destination $tempZip
    if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    
    Expand-Archive -Path $tempZip -DestinationPath $tempDir -Force
    
    $xmlPath = Join-Path $tempDir "word\document.xml"
    if (Test-Path $xmlPath) {
        [xml]$docXml = Get-Content -Path $xmlPath -Raw
        $nsManager = New-Object System.Xml.XmlNamespaceManager($docXml.NameTable)
        $nsManager.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
        
        $paragraphs = $docXml.SelectNodes("//w:p", $nsManager)
        $textContent = [System.Text.StringBuilder]::new()
        foreach ($p in $paragraphs) {
            $texts = $p.SelectNodes(".//w:t", $nsManager)
            $pText = ""
            foreach ($t in $texts) {
                if ($t.InnerText) { $pText += $t.InnerText }
            }
            if ($pText) {
                [void]$textContent.AppendLine($pText)
            }
        }
        $fullText = $textContent.ToString()
        $outPath = Join-Path $FolderPath "$($file.BaseName).txt"
        Set-Content -Path $outPath -Value $fullText -Encoding UTF8
        Write-Host "Extracted to $($file.BaseName).txt"
    }
    
    Remove-Item $tempZip -Force
    Remove-Item $tempDir -Recurse -Force
}
