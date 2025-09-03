# 🌱 BioToken App Deployment & Einbettung

## 📋 Überblick

Diese Anleitung erklärt, wie Sie Ihre BioToken Flutter-App auf einem Webserver bereitstellen und in bestehende Webseiten einbetten können.

## 🚀 Schritt 1: Flutter Web Build

```bash
# Im Projekt-Verzeichnis ausführen
flutter build web --release

# Optional: Mit Custom Base Href
flutter build web --release --base-href="/biotoken/"
```

Die Web-Dateien werden im `build/web/` Ordner erstellt.

## 📁 Schritt 2: Dateien hochladen

Laden Sie folgende Dateien auf Ihren Webserver hoch:

### Hauptverzeichnis (z.B. `/biotoken/`):
```
📁 your-website.com/biotoken/
├── index.html
├── main.dart.js
├── flutter.js
├── flutter_bootstrap.js
├── favicon.png
├── manifest.json
├── 📁 assets/
├── 📁 icons/
└── 📁 canvaskit/
```

### Einbettungsskript:
```
📁 your-website.com/scripts/
└── embed_script.js
```

## ⚙️ Schritt 3: Server-Konfiguration

### Apache (.htaccess):
```apache
# CORS Headers für Einbettung
Header always set Access-Control-Allow-Origin "*"
Header always set Access-Control-Allow-Methods "GET, POST, OPTIONS"
Header always set Access-Control-Allow-Headers "Content-Type"

# MIME Types für Flutter
AddType application/javascript .js
AddType application/json .json
AddType image/svg+xml .svg

# Caching
<FilesMatch "\.(js|css|png|jpg|jpeg|gif|ico|svg)$">
    ExpiresActive On
    ExpiresDefault "access plus 1 month"
</FilesMatch>
```

### Nginx:
```nginx
location /biotoken/ {
    add_header Access-Control-Allow-Origin *;
    add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS';
    add_header Access-Control-Allow-Headers 'Content-Type';
    
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

## 🔧 Schritt 4: Einbettungsskript konfigurieren

Bearbeiten Sie `embed_script.js` und setzen Sie die korrekte URL:

```javascript
// Zeile ~10 in embed_script.js ändern:
baseUrl: options.baseUrl || 'https://ihre-domain.com/biotoken',
```

## 📝 Schritt 5: In Webseite einbetten

### Methode 1: Einfache JavaScript-Einbettung

```html
<!DOCTYPE html>
<html>
<head>
    <title>Meine Webseite</title>
</head>
<body>
    <h1>Willkommen auf meiner Webseite</h1>
    
    <!-- Container für die BioToken App -->
    <div id="biotoken-container"></div>
    
    <!-- Einbettungsskript laden -->
    <script src="https://ihre-domain.com/scripts/embed_script.js"></script>
    
    <!-- App initialisieren -->
    <script>
        const biotoken = new BioTokenEmbed({
            containerId: 'biotoken-container',
            baseUrl: 'https://ihre-domain.com/biotoken',
            width: '100%',
            height: '600px'
        });
        biotoken.embed();
    </script>
</body>
</html>
```

### Methode 2: Automatische Einbettung mit Data-Attributen

```html
<!-- Noch einfacher - automatisches Laden -->
<div 
    id="my-biotoken-app" 
    data-biotoken-embed
    data-biotoken-url="https://ihre-domain.com/biotoken"
    data-biotoken-width="100%"
    data-biotoken-height="700px"
></div>

<script src="https://ihre-domain.com/scripts/embed_script.js"></script>
```

### Methode 3: WordPress Shortcode

Für WordPress können Sie einen Shortcode erstellen:

```php
// In functions.php
function biotoken_shortcode($atts) {
    $atts = shortcode_atts(array(
        'width' => '100%',
        'height' => '600px',
        'url' => 'https://ihre-domain.com/biotoken'
    ), $atts);
    
    wp_enqueue_script('biotoken-embed', 'https://ihre-domain.com/scripts/embed_script.js');
    
    $container_id = 'biotoken-' . uniqid();
    
    return sprintf(
        '<div id="%s" data-biotoken-embed data-biotoken-url="%s" data-biotoken-width="%s" data-biotoken-height="%s"></div>',
        $container_id,
        esc_url($atts['url']),
        esc_attr($atts['width']),
        esc_attr($atts['height'])
    );
}
add_shortcode('biotoken', 'biotoken_shortcode');

// Verwendung: [biotoken width="100%" height="700px"]
```

## 🎨 Schritt 6: Styling anpassen

```css
/* Custom CSS für die eingebettete App */
.biotoken-embed {
    border-radius: 12px;
    box-shadow: 0 10px 40px rgba(0,0,0,0.1);
    overflow: hidden;
    margin: 40px 0;
}

/* Responsive Design */
@media (max-width: 768px) {
    .biotoken-embed {
        height: 500px !important;
        margin: 20px 0;
    }
}

@media (max-width: 480px) {
    .biotoken-embed {
        height: 400px !important;
        border-radius: 8px;
    }
}
```

## 🔒 Schritt 7: Sicherheit & Performance

### Content Security Policy (CSP):
```html
<meta http-equiv="Content-Security-Policy" 
      content="frame-src 'self' https://ihre-domain.com; 
               script-src 'self' 'unsafe-inline' https://ihre-domain.com;">
```

### Performance Optimierung:
```html
<!-- Preload kritische Ressourcen -->
<link rel="preload" href="https://ihre-domain.com/biotoken/main.dart.js" as="script">
<link rel="preconnect" href="https://ihre-domain.com">

<!-- Lazy Loading für nicht-kritische Einbettungen -->
<div data-biotoken-embed data-biotoken-loading="lazy"></div>
```

## 🧪 Schritt 8: Testen

### Lokaler Test:
```bash
# Python Server für lokalen Test
python -m http.server 8000
# oder
python3 -m http.server 8000

# Dann öffnen: http://localhost:8000
```

### Checkliste:
- [ ] App lädt korrekt in iFrame
- [ ] Responsive Design funktioniert
- [ ] Kein CORS-Fehler in Browser Console
- [ ] Touch/Maus-Interaktion funktioniert
- [ ] Fullscreen-Modus verfügbar (falls aktiviert)
- [ ] Performance ist akzeptabel

## 🔧 Troubleshooting

### Problem: "Mixed Content" Fehler
**Lösung:** Stellen Sie sicher, dass sowohl die Hauptseite als auch die eingebettete App über HTTPS laufen.

### Problem: CORS-Fehler
**Lösung:** Konfigurieren Sie CORS-Headers auf dem Server (siehe Schritt 3).

### Problem: App lädt nicht
**Lösung:** 
1. Überprüfen Sie die `baseUrl` im Einbettungsskript
2. Kontrollieren Sie Browser Console auf Fehler
3. Testen Sie die App-URL direkt im Browser

### Problem: Performance-Probleme
**Lösung:**
1. Verwenden Sie `loading="lazy"` für nicht-sichtbare Einbettungen
2. Implementieren Sie Caching (siehe Server-Konfiguration)
3. Komprimieren Sie Dateien mit gzip

## 📞 Support

Bei Problemen können Sie:
1. Browser Developer Tools → Console überprüfen
2. Netzwerk-Tab auf failed requests prüfen
3. Die Beispielseite `embed_examples.html` als Referenz verwenden

## 🔄 Updates

Bei App-Updates:
1. Neuen Flutter Web Build erstellen
2. Dateien auf Server aktualisieren
3. Browser-Cache leeren (oder Versionierung verwenden)
4. Eingebettete Apps werden automatisch aktualisiert