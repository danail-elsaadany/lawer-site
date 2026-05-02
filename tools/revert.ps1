$ErrorActionPreference = "Stop"

$workspace = "c:\Users\Mohamed HatemMubarak\Desktop\‏‏New folder (2) - نسخة"
$files = Get-ChildItem -Path $workspace -Recurse -Filter "*.html" | Where-Object { $_.FullName -notmatch "\\node_modules\\" }

$code = @"
using System;
using System.IO;
using System.Text.RegularExpressions;
using System.Text;

public class RevertI18n {
    public static void Run(string[] files) {
        int count = 0;
        
        // Match data-key="anything"
        Regex dataKeyRegex = new Regex(@"\s*data-key=""[^""]*""", RegexOptions.IgnoreCase);
        
        // Match script tags
        Regex scriptRegex1 = new Regex(@"\s*<script[^>]*src=""[^""]*translations\.js""[^>]*></script>", RegexOptions.IgnoreCase);
        Regex scriptRegex2 = new Regex(@"\s*<script[^>]*src=""[^""]*i18n\.js""[^>]*></script>", RegexOptions.IgnoreCase);
        
        // Match lang switcher
        Regex langSwitcherRegex = new Regex(@"\s*<div class=""lang-switcher"">.*?</div>", RegexOptions.IgnoreCase | RegexOptions.Singleline);
        
        foreach (string file in files) {
            string content = File.ReadAllText(file);
            string originalContent = content;
            
            content = dataKeyRegex.Replace(content, "");
            content = scriptRegex1.Replace(content, "");
            content = scriptRegex2.Replace(content, "");
            content = langSwitcherRegex.Replace(content, "");
            
            if (content != originalContent) {
                File.WriteAllText(file, content, Encoding.UTF8);
                count++;
            }
        }
        
        Console.WriteLine("Reverted " + count + " files.");
    }
}
"@

Add-Type -TypeDefinition $code -Language CSharp
[RevertI18n]::Run($files.FullName)
