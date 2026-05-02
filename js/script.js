const CONTACT_INFO = {
    whatsapp_primary: "+447839199992",
    whatsapp_secondary: "+971544428286",
    email: "Daniel@lawservice.ae",
    address: "Office 1105, Iris Bay Tower, Business Bay, Dubai, UAE"
};

document.addEventListener('DOMContentLoaded', () => {
    // ------------------------------------
    // 0. Navigation Active State
    // ------------------------------------
    const currentPath = window.location.pathname;
    const navLinks = document.querySelectorAll('.nav-links a');

    navLinks.forEach(link => {
        const href = link.getAttribute('href');
        // Remove active class initially
        link.classList.remove('active');

        if (href && href !== '#') {
            const isHomePage = currentPath.endsWith('index.html') || currentPath === '/' || currentPath.endsWith('نسخة/');

            if (isHomePage) {
                if (href === 'index.html') {
                    link.classList.add('active');
                }
            } else {
                if (currentPath.endsWith(href)) {
                    link.classList.add('active');
                }
            }
        }
    });

    // ------------------------------------
    // 1. Mobile Menu Toggle & Dropdowns
    // ------------------------------------
    const menuToggle = document.querySelector('.menu-toggle');
    const navMenu = document.querySelector('.nav-menu');
    const dropdownToggles = document.querySelectorAll('.dropdown-toggle');

    if (menuToggle && navMenu) {
        menuToggle.addEventListener('click', () => {
            navMenu.classList.toggle('open');
            // Change icon
            const icon = menuToggle.querySelector('i');
            if (navMenu.classList.contains('open')) {
                icon.classList.remove('fa-bars');
                icon.classList.add('fa-times');
            } else {
                icon.classList.remove('fa-times');
                icon.classList.add('fa-bars');
            }
        });
    }

    // Handle dropdown clicks on mobile devices
    dropdownToggles.forEach(toggle => {
        toggle.addEventListener('click', (e) => {
            if (window.innerWidth <= 991) {
                e.preventDefault();
                const parentLi = toggle.parentElement;
                parentLi.classList.toggle('active');
            }
        });
    });

    // ------------------------------------
    // 2. Scroll Effect on Header
    // ------------------------------------
    const header = document.querySelector('.main-header') || document.querySelector('header');

    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            header.classList.add('scrolled');
        } else {
            header.classList.remove('scrolled');
        }
    });

    // Translation logic has been moved to js/i18n.js and js/translations.js

    // ------------------------------------
    // 4. Set Dynamic Year in Footer
    // ------------------------------------
    const yearSpan = document.getElementById('currentYear');
    if (yearSpan) {
        yearSpan.textContent = new Date().getFullYear();
    }

    // ------------------------------------
    // 5. Global Contact Data Integration
    // ------------------------------------
    function applyGlobalContactData() {
        // Find and replace text instances
        const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null, false);
        let node;
        while (node = walker.nextNode()) {
            let text = node.nodeValue;
            if (text.includes('info@alhammadi-law.com')) {
                node.nodeValue = text.replace('info@alhammadi-law.com', CONTACT_INFO.email);
            }
            if (text.includes('+971 000 0000 00')) {
                node.nodeValue = text.replace('+971 000 0000 00', CONTACT_INFO.whatsapp_secondary);
            }
            if (text.includes('دبي، الإمارات العربية المتحدة') || text.includes('Dubai, United Arab Emirates')) {
                node.nodeValue = text.replace('دبي، الإمارات العربية المتحدة', CONTACT_INFO.address).replace('Dubai, United Arab Emirates', CONTACT_INFO.address);
            }
        }

        // Redirect all WhatsApp Links to Primary WhatsApp Number
        const cleanWaNumber = CONTACT_INFO.whatsapp_primary.replace('+', '');
        document.querySelectorAll('a[href]').forEach(link => {
            if (link.href.includes('wa.me') && !link.hasAttribute('data-contact-handled')) {
                // If it explicitly has a text search param, keep it, otherwise generic message
                const urlObj = new URL(link.href);
                let textParam = urlObj.searchParams.get('text');
                link.href = `https://wa.me/${cleanWaNumber}` + (textParam ? `?text=${encodeURIComponent(textParam)}` : '');
                link.setAttribute('data-contact-handled', 'true');
            }
        });

        // Intercept all Form Submissions and convert them to WhatsApp Messages
        document.querySelectorAll('form').forEach(form => {
            if (form.hasAttribute('data-contact-handled')) return;

            form.addEventListener('submit', (e) => {
                e.preventDefault(); // Stop normal submission (no emails)

                const formData = new FormData(form);
                const name = formData.get('name') || '';
                const phone = formData.get('phone') || '';
                const email = formData.get('email') || '';
                const message = formData.get('message') || '';

                let waText = `مرحباً، أود الاستفسار عن هذه الخدمة\n\n`;
                if (name) waText += `الاسم: ${name}\n`;
                if (phone) waText += `رقم الهاتف: ${phone}\n`;
                if (email) waText += `البريد الإلكتروني: ${email}\n`;
                if (message) waText += `الرسالة/الاستفسار: ${message}\n`;

                const waUrl = `https://wa.me/${cleanWaNumber}?text=${encodeURIComponent(waText)}`;
                window.open(waUrl, '_blank');
            });
            form.setAttribute('data-contact-handled', 'true');
        });
    }

    // ------------------------------------
    // 6. Statistics Counter Animation
    // ------------------------------------
    const statsSection = document.querySelector('.stats-section');
    const statItems = document.querySelectorAll('.stat-item');
    const statNumbers = document.querySelectorAll('.stat-number');
    let counted = false;

    if (statsSection) {
        const statsObserver = new IntersectionObserver((entries) => {
            if (entries[0].isIntersecting && !counted) {
                counted = true;

                // Add animate-in class for fade up stagger effect
                statItems.forEach(item => item.classList.add('animate-in'));

                // Count up animation
                statNumbers.forEach(num => {
                    const target = +num.getAttribute('data-target');
                    const prefix = num.getAttribute('data-prefix') || '';
                    const suffix = num.getAttribute('data-suffix') || '';
                    const duration = 2000; // 2 seconds
                    const increment = target / (duration / 16); // 60fps

                    let current = 0;

                    const updateCount = () => {
                        current += increment;
                        if (current < target) {
                            num.innerText = prefix + Math.ceil(current).toLocaleString('en-US') + suffix;
                            requestAnimationFrame(updateCount);
                        } else {
                            num.innerText = prefix + target.toLocaleString('en-US') + suffix;
                        }
                    };

                    updateCount();
                });
            }
        }, { threshold: 0.3 });

        statsObserver.observe(statsSection);
    }

    applyGlobalContactData();

    // Optional: Re-apply if translator modifies DOM
    const originalUpdateLang = updateLanguage;
    updateLanguage = function (lang) {
        originalUpdateLang(lang);
        applyGlobalContactData();
    };
});

// HERO SLIDER AUTO SWITCH
let currentSlide = 0;
const slides = document.querySelectorAll(".hero-slide");

function showSlide(next) {
    slides[currentSlide].classList.remove("active");
    slides[currentSlide].classList.add("exit");

    currentSlide = next;

    if (currentSlide >= slides.length) currentSlide = 0;

    slides[currentSlide].classList.remove("exit");
    slides[currentSlide].classList.add("active");
}

setInterval(() => {
    let next = currentSlide + 1;
    if (next >= slides.length) next = 0;
    showSlide(next);
}, 4000);
const toggleBtn = document.getElementById("toggleBtn");
const aboutText = document.getElementById("aboutText");

let expanded = false;

toggleBtn.addEventListener("click", () => {
    if (!expanded) {
        aboutText.classList.remove("collapsed");
        aboutText.style.maxHeight = aboutText.scrollHeight + "px";
        toggleBtn.textContent = "إخفاء";
    } else {
        aboutText.classList.add("collapsed");
        aboutText.style.maxHeight = "120px";
        toggleBtn.textContent = "اقرأ المزيد";
    }

    expanded = !expanded;
});
const faqItems = document.querySelectorAll(".faq-item");

faqItems.forEach(item => {
    const btn = item.querySelector(".faq-question");

    btn.addEventListener("click", () => {

        // close all
        faqItems.forEach(i => {
            if (i !== item) {
                i.classList.remove("active");
                i.querySelector(".icon").textContent = "+";
            }
        });

        // toggle current
        item.classList.toggle("active");

        const icon = item.querySelector(".icon");
        icon.textContent = item.classList.contains("active") ? "-" : "+";
    });
});
document.addEventListener("DOMContentLoaded", function () {

    const track = document.querySelector(".articles-track");
    const nextBtn = document.querySelector(".articles-arrow.right");
    const prevBtn = document.querySelector(".articles-arrow.left");

    if (!track) return;

    function getScrollAmount() {
        return track.offsetWidth;
    }

    function nextSlide() {
        track.scrollBy({
            left: getScrollAmount(),
            behavior: "smooth"
        });
    }

    function prevSlide() {
        track.scrollBy({
            left: -getScrollAmount(),
            behavior: "smooth"
        });
    }

    nextBtn.addEventListener("click", nextSlide);
    prevBtn.addEventListener("click", prevSlide);

    // Auto Scroll
    let auto = setInterval(nextSlide, 4000);

    track.addEventListener("mouseenter", () => clearInterval(auto));
    track.addEventListener("mouseleave", () => {
        auto = setInterval(nextSlide, 4000);
    });

});
document.querySelectorAll(".dropdown > a").forEach(item => {
    item.addEventListener("click", function (e) {

        // لو موبايل فقط
        if (window.innerWidth <= 991) {
            e.preventDefault();

            const parent = this.parentElement;

            // اقفل الباقي
            document.querySelectorAll(".dropdown").forEach(el => {
                if (el !== parent) el.classList.remove("active");
            });

            // افتح الحالي
            parent.classList.toggle("active");
        }

    });
});
// MOBILE DROPDOWN FIX
document.addEventListener("DOMContentLoaded", function () {

    const dropdowns = document.querySelectorAll(".dropdown > a");

    dropdowns.forEach(link => {
        link.addEventListener("click", function (e) {

            // شغل الكود بس في الموبايل
            if (window.innerWidth <= 991) {
                e.preventDefault();

                const parent = this.parentElement;

                // قفل أي dropdown مفتوح
                document.querySelectorAll(".dropdown").forEach(d => {
                    if (d !== parent) {
                        d.classList.remove("active");
                    }
                });

                // toggle الحالي
                parent.classList.toggle("active");
            }

        });
    });

});
document.querySelectorAll(".dropdown > a").forEach(a => {
    a.addEventListener("click", function (e) {
        if (window.innerWidth <= 991) {
            e.preventDefault();
        }
    });
});
