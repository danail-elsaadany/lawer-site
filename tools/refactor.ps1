$ErrorActionPreference = "Stop"

$workspace = "c:\Users\Mohamed HatemMubarak\Desktop\‏‏New folder (2) - نسخة"
$files = Get-ChildItem -Path $workspace -Recurse -Filter "*.html" | Where-Object { $_.FullName -notmatch "\\node_modules\\" }

$code = @"
using System;
using System.IO;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System.Text;

public class Refactor {
    public static void Run(string[] files, string outJsonPath) {
        int keyIndex = 1;
        Dictionary<string, string> dict = new Dictionary<string, string>();
        Dictionary<string, string> commonDict = new Dictionary<string, string>();

        // We manually insert the base translations we already defined
        var baseTranslations = new Dictionary<string, string> {
            {"nav_home", "الصفحة الرئيسية"}, {"nav_about", "من نحن"}, {"nav_team", "فريق المحامين"},
            {"nav_services", "الخدمات"}, {"nav_articles", "المقالات القانونية"}, {"nav_notary", "كاتب العدل"},
            {"nav_trademarks", "العلامات التجارية"}, {"nav_media", "المركز الإعلامي"}, {"nav_terms", "الشروط والأحكام"},
            {"nav_contact", "تواصل معنا"}, {"nav_trademark_monitoring", "مراقبة العلامة التجارية"},
            {"nav_internal_training", "برنامج التدريب الداخلي"}, {"nav_global_partners", "الشركاء العالميين"},
            {"nav_attestation", "خدمات التصديق"}, {"nav_legal_drafting", "خدمات الصياغة القانونية"},
            {"cta_need_consultation", "هل تحتاج إلى استشارة قانونية؟"},
            {"cta_available_24_7", "متواجدون على مدار الساعة للرد على مكالماتكم وتقديم أفضل الحلول القانونية التي تلبي احتياجاتكم."},
            {"cta_contact_us", "تواصل معنا"}, {"contact_info_title", "معلومات التواصل"},
            {"contact_info_desc", "لا تتردد في الاتصال بنا للحصول على الدعم القانوني الفوري."},
            {"contact_form_title", "أرسل رسالتك"}, {"form_name", "الاسم الكامل"},
            {"form_phone", "رقم الهاتف"}, {"form_email", "البريد الإلكتروني"},
            {"form_message", "رسالتك أو استفسارك القانوني..."}, {"form_submit", "إرسال الرسالة"},
            {"form_whatsapp_submit", "إرسال عبر واتساب"}, {"footer_desc", "نحن في جاسم الحمادي نفخر بثقة عملائنا، ونلتزم بتقديم الدعم القانوني اللازم لهم."},
            {"footer_featured_services", "خدمات مختارة"}, {"footer_important_links", "روابط هامة"},
            {"footer_contact_title", "التواصل"}, {"footer_rights", "جميع الحقوق محفوظة - مكتب جاسم الحمادي للمحاماة والاستشارات القانونية."}
        };

        foreach(var kvp in baseTranslations) {
            dict[kvp.Key] = kvp.Value;
            commonDict[kvp.Value] = kvp.Key;
        }
        
        // Matches HTML tags containing purely text inside them
        Regex tagRegex = new Regex(@"<(h[1-6]|p|li|a|span|button|label|strong|b|em|i|th|td)([^>]*)>([^<]+)</\1>", RegexOptions.IgnoreCase | RegexOptions.Singleline);
        // Matches placeholder="" or value="" in input/textarea
        Regex attrRegex = new Regex(@"<(input|textarea)([^>]+)(placeholder|value)=""([^""]+)""([^>]*)>", RegexOptions.IgnoreCase);

        foreach (string file in files) {
            string content = File.ReadAllText(file);
            bool modified = false;
            
            // 1. Process Tags
            string newContent = tagRegex.Replace(content, match => {
                string tag = match.Groups[1].Value;
                string attrs = match.Groups[2].Value;
                string text = match.Groups[3].Value.Trim();
                
                if (string.IsNullOrWhiteSpace(text) || text.Length < 2) return match.Value;
                if (Regex.IsMatch(text, @"^[\d\s\p{P}]+$")) return match.Value; 
                if (attrs.Contains("data-key")) return match.Value; 
                
                string key = "";
                if (commonDict.ContainsKey(text)) {
                    key = commonDict[text];
                } else {
                    key = "txt_" + keyIndex++;
                    commonDict[text] = key;
                    dict[key] = text;
                }
                
                modified = true;
                return "<" + tag + attrs + " data-key=\"" + key + "\">" + text + "</" + tag + ">";
            });

            // 2. Process Inputs
            newContent = attrRegex.Replace(newContent, match => {
                string tag = match.Groups[1].Value;
                string beforeAttr = match.Groups[2].Value;
                string attrName = match.Groups[3].Value;
                string attrValue = match.Groups[4].Value;
                string afterAttr = match.Groups[5].Value;

                if (string.IsNullOrWhiteSpace(attrValue)) return match.Value;
                if (beforeAttr.Contains("data-key") || afterAttr.Contains("data-key")) return match.Value;

                string key = "";
                if (commonDict.ContainsKey(attrValue)) {
                    key = commonDict[attrValue];
                } else {
                    key = "txt_" + keyIndex++;
                    commonDict[attrValue] = key;
                    dict[key] = attrValue;
                }

                modified = true;
                return "<" + tag + beforeAttr + attrName + "=\"" + attrValue + "\" data-key=\"" + key + "\"" + afterAttr + ">";
            });
            
            // 3. Inject Scripts
            if (!newContent.Contains("js/i18n.js")) {
                newContent = newContent.Replace("</body>", "    <script src=\"js/translations.js\"></script>\n    <script src=\"js/i18n.js\"></script>\n</body>");
                if (file.Contains(@"\services\")) {
                    newContent = newContent.Replace("src=\"js/translations.js\"", "src=\"../js/translations.js\"").Replace("src=\"js/i18n.js\"", "src=\"../js/i18n.js\"");
                }
                modified = true;
            }

            if (modified) {
                File.WriteAllText(file, newContent, Encoding.UTF8);
            }
        }
        
        // Write translations.js
        StringBuilder sb = new StringBuilder();
        sb.AppendLine("const translations = {");
        foreach(var kvp in dict) {
            string safeText = kvp.Value.Replace("\"", "\\\"").Replace("\n", " ").Replace("\r", "");
            sb.AppendLine("    \"" + kvp.Key + "\": { \"ar\": \"" + safeText + "\", \"en\": \"" + safeText + "\" },");
        }
        sb.AppendLine("};");
        File.WriteAllText(outJsonPath, sb.ToString(), Encoding.UTF8);
        Console.WriteLine("Refactored " + files.Length + " files and extracted " + dict.Count + " translations.");
    }
}
"@

Add-Type -TypeDefinition $code -Language CSharp
[Refactor]::Run($files.FullName, "$workspace\js\translations.js")
