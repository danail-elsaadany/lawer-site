const fs = require('fs');
const path = require('path');

const rootDir = process.cwd();

try {
    const indexContent = fs.readFileSync(path.join(rootDir, 'index.html'), 'utf-8');
    const headerMatch = indexContent.match(/<header class="main-header">[\s\S]*?<\/header>/);
    if (!headerMatch) {
        console.error("Could not find header in index.html");
        process.exit(1);
    }
    
    const newHeader = headerMatch[0];
    
    const adjustHeaderForServices = (header) => {
        let h = header;
        const pages = [
            "index.html", "about.html", "team.html", "services.html", 
            "articles.html", "notary.html", "private-notary.html", 
            "legal-drafting.html", "trademark.html", "trademark-monitoring.html", 
            "trademark-search.html", "global-partners.html", "media-center.html", 
            "internal-training.html", "terms.html", "contact.html"
        ];
        
        pages.forEach(page => {
            h = h.replace(new RegExp(`href="${page}"`, 'g'), `href="../${page}"`);
        });
        
        h = h.replace(/src="assets\//g, 'src="../assets/');
        h = h.replace(/href='services\//g, "href='../services/");
        
        return h;
    };
    
    const headerPattern = /<header.*?>[\s\S]*?<\/header>/;

    const processFiles = (dir) => {
        const files = fs.readdirSync(dir);
        for (const file of files) {
            const filepath = path.join(dir, file);
            const stat = fs.statSync(filepath);
            
            if (stat.isDirectory() && (file === 'services' || file === 'assets')) {
                processFiles(filepath);
            } else if (file.endsWith('.html')) {
                let content = fs.readFileSync(filepath, 'utf-8');
                
                let headerToInject = newHeader;
                if (filepath.includes(path.sep + 'services' + path.sep) || filepath.includes(path.sep + 'assets' + path.sep)) {
                    headerToInject = adjustHeaderForServices(newHeader);
                }
                
                if (headerPattern.test(content)) {
                    const newContent = content.replace(headerPattern, headerToInject);
                    if (newContent !== content) {
                        fs.writeFileSync(filepath, newContent, 'utf-8');
                        console.log(`Updated ${filepath}`);
                    }
                }
            }
        }
    };
    
    processFiles(rootDir);
    console.log("Done unifying headers.");

} catch (err) {
    console.error(err);
}
