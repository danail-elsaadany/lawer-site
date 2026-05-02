param(
    [string]$LinksFile,
    [string]$OutputDir
)

$links = Get-Content -Path $LinksFile -Raw -Encoding UTF8

# Parse the links
$lines = $links -split "`n"
$gridHtml = "<div class='services-grid'>"

foreach ($line in $lines) {
    if ($line -match "href='(.*?)'.*>(.*?)<\/a>") {
        $url = $matches[1]
        $title = $matches[2]
        
        $gridHtml += "
        <div class='service-card'>
            <img src='assets/images/logo png2.png' onerror=`"this.src='assets/images/logo png.png'`" alt='$title'>
            <div class='service-card-body'>
                <h3>$title</h3>
                <p>خدمات قانونية متخصصة ومتميزة في $title .</p>
                <a href='$url' class='service-link'>المزيد <i class='fas fa-arrow-left'></i></a>
            </div>
        </div>
        "
    }
}
$gridHtml += "</div>"

$html = @"
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>مجالات خدماتنا - جاسم الحمادي للمحاماة</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Tajawal:wght@400;500;700;800&family=Cairo:wght@400;600;700&display=swap" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/style.css">
</head>
<body style="background-color: var(--bg-light);">

    <!-- Header & Navigation -->
    <header>
        <div class="nav-container">
            <div class="logo">
                <a href="index.html">
                    <img src="assets/images/logo png.png" alt="جاسم الحمادي للمحاماة">
                </a>
            </div>
            
            <div class="menu-toggle"><i class="fas fa-bars"></i></div>
            
            <ul class="nav-links">
                <li><a href="index.html">الصفحة الرئيسية</a></li>
                <li class="dropdown">
                    <a href="about.html">من نحن <i class="fas fa-chevron-down"></i></a>
                    <div class="dropdown-content">
                        <a href="articles.html">المقالات والمدونات القانونية</a>
                    </div>
                </li>
                <li><a href="team.html">فريق المحامين</a></li>
                <li class="dropdown">
                    <a href="services.html" class="active">مجالات خدماتنا <i class="fas fa-chevron-down"></i></a>
                    <div class="dropdown-content" style="max-height: 400px; overflow-y: scroll;">
                        $links
                    </div>
                </li>
                <li><a href="notary.html">خدمات التصديق</a></li>
                <li><a href="private-notary.html">كاتب العدل الخاص</a></li>
                <li><a href="legal-drafting.html">الصياغة القانونية</a></li>
                <li class="dropdown">
                    <a href="trademark.html">العلامة التجارية <i class="fas fa-chevron-down"></i></a>
                    <div class="dropdown-content">
                        <a href="trademark.html">بحث العلامات التجارية</a>
                        <a href="trademark-monitoring.html">مراقبة العلامة التجارية</a>
                    </div>
                </li>
                <li><a href="global-partners.html">الشركاء العالميين</a></li>
                <li class="dropdown">
                    <a href="media-center.html">المركز الاعلامى <i class="fas fa-chevron-down"></i></a>
                    <div class="dropdown-content">
                        <a href="media-center.html">اخبار المركز الاعلامى</a>
                        <a href="internal-training.html">برنامج التدريب الداخلي</a>
                    </div>
                </li>
                <li><a href="terms.html">الشروط والاحكام</a></li>
                <li><a href="contact.html">تواصل معنا</a></li>
            </ul>
        </div>
    </header>

    <div class="service-header">
        <div class="container">
            <h1>جميع مجالات خدماتنا</h1>
            <p style="font-size: 18px; margin-top: 15px;">نقدم مجموعة متكاملة من الخدمات القانونية وفق أعلى المعايير المهنية</p>
        </div>
    </div>

    <!-- Featured Services Section -->
    <section class="section container">
        $gridHtml
    </section>

    <!-- Global CTA Section -->
    <section class="cta-section">
        <div class="container">
            <h2>هل تحتاج إلى استشارة قانونية؟</h2>
            <p>متواجدون على مدار الساعة للرد على مكالماتكم وتقديم أفضل الحلول القانونية التي تلبي احتياجاتكم.</p>
            <a href="contact.html" class="btn">تواصل معنا الآن</a>
        </div>
    </section>

    <!-- Global Contact Form Section -->
    <section class="contact-section" id="contact">
        <div class="container">
            <div class="contact-wrapper">
                <div class="contact-info">
                    <h3>معلومات التواصل</h3>
                    <p>لا تتردد في الاتصال بنا للحصول على الدعم القانوني الفوري.</p>
                    <div style="margin-top: 40px;">
                        <p><i class="fas fa-map-marker-alt"></i> دبي، الإمارات العربية المتحدة</p>
                        <p><i class="fas fa-phone-alt"></i> +971 000 0000 00</p>
                        <p><i class="fas fa-envelope"></i> info@alhammadi-law.com</p>
                    </div>
                </div>
                <div class="contact-form">
                    <h3>أرسل رسالتك</h3>
                    <form action="#" method="POST">
                        <div class="form-group">
                            <input type="text" class="form-control" name="name" placeholder="الاسم الكامل" required>
                        </div>
                        <div class="form-group">
                            <input type="tel" class="form-control" name="phone" placeholder="رقم الهاتف" required>
                        </div>
                        <div class="form-group">
                            <input type="email" class="form-control" name="email" placeholder="البريد الإلكتروني" required>
                        </div>
                        <div class="form-group">
                            <textarea class="form-control" name="message" placeholder="رسالتك أو استفسارك القانوني..." required></textarea>
                        </div>
                        <button type="submit" class="btn" style="width: 100%;">إرسال الرسالة</button>
                    </form>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer>
        <div class="container">
            <div class="footer-grid">
                <div>
                    <div class="footer-logo">
                        <img src="assets/images/logo png.png" alt="جاسم الحمادي">
                    </div>
                    <p class="footer-desc">نحن في جاسم الحمادي نفخر بثقة عملائنا، ونلتزم بتقديم الدعم القانوني اللازم لهم مهما كانت طبيعة أو تعقيد القضية. اعلم لكي تسلم… لأن في القانون حياة.</p>
                </div>
                <div>
                    <h4 class="footer-title">خدمات مختارة</h4>
                    <ul class="footer-links">
                        <li><a href="services/service-1.html">قانون الشركات</a></li>
                        <li><a href="services/service-6.html">القضايا الجزائية</a></li>
                        <li><a href="services/service-4.html">المنازعات العقارية</a></li>
                        <li><a href="services/service-19.html">الأحوال الشخصية</a></li>
                    </ul>
                </div>
                <div>
                    <h4 class="footer-title">روابط هامة</h4>
                    <ul class="footer-links">
                        <li><a href="about.html">من نحن</a></li>
                        <li><a href="services.html">مجالات الخدمات</a></li>
                        <li><a href="terms.html">الشروط والأحكام</a></li>
                        <li><a href="contact.html">تواصل معنا</a></li>
                    </ul>
                </div>
                <div>
                    <h4 class="footer-title">التواصل</h4>
                    <ul class="footer-contact">
                        <li><i class="fas fa-phone-alt"></i> +971 000 0000 00</li>
                        <li><i class="fas fa-envelope"></i> info@alhammadi-law.com</li>
                        <li><i class="fas fa-map-marker-alt"></i> دبي، الإمارات العربية المتحدة</li>
                    </ul>
                </div>
            </div>
            <div class="footer-bottom">
                <p>&copy; <span id="currentYear"></span> جميع الحقوق محفوظة - مكتب جاسم الحمادي للمحاماة والاستشارات القانونية.</p>
            </div>
        </div>
    </footer>

    <!-- WhatsApp Floating Button -->
    <a href="https://wa.me/971000000000" target="_blank" class="whatsapp-float">
        <i class="fab fa-whatsapp"></i>
    </a>

    <script src="js/script.js"></script>
</body>
</html>
"@

$outPath = Join-Path $OutputDir "services.html"
Set-Content -Path $outPath -Value $html -Encoding UTF8
Write-Host "Generated services.html"
