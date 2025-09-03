# BioToken für Joomla - Installationsanleitung

## 📋 **Übersicht**
Diese Anleitung zeigt Ihnen drei verschiedene Methoden, um Ihre BioToken Flutter-App in eine Joomla-Website einzubinden.

## 🚀 **Methode 1: Custom Joomla Module (Empfohlen)**

### Schritt 1: Modul-Dateien vorbereiten
1. Erstellen Sie einen neuen Ordner: `mod_biotoken/`
2. Kopieren Sie folgende Dateien in den Ordner:
   - `joomla_module.php` → `mod_biotoken.php`
   - `joomla_module.xml` → `mod_biotoken.xml`

### Schritt 2: Modul installieren
1. **Joomla Admin-Panel** öffnen
2. Gehen Sie zu **Erweiterungen → Verwalten → Installieren**
3. Wählen Sie **"Paket-Datei hochladen"**
4. Erstellen Sie eine ZIP-Datei mit den Modul-Dateien
5. Laden Sie die ZIP-Datei hoch und installieren Sie das Modul

### Schritt 3: Modul konfigurieren
1. Gehen Sie zu **Erweiterungen → Module**
2. Suchen Sie **"BioToken Flutter App"** und klicken Sie darauf
3. Konfigurieren Sie die Einstellungen:
   ```
   BioToken App URL: https://ihre-domain.com/biotoken/
   Width: 100%
   Height: 600px
   Show Loading Indicator: Ja
   ```
4. Wählen Sie die **Position** (z.B. "Main Body", "Right Sidebar")
5. Stellen Sie sicher, dass **Status: Veröffentlicht** ist
6. **Speichern & Schließen**

---

## 📝 **Methode 2: Custom HTML Module**

### Schritt 1: HTML Module erstellen
1. **Joomla Admin-Panel** → **Erweiterungen → Module**
2. Klicken Sie **"Neu"** → Wählen Sie **"Custom HTML"**

### Schritt 2: HTML-Code einfügen
```html
<div id="biotoken-app" style="width: 100%; height: 600px; margin: 20px 0;">
    <div id="loading" style="display: flex; align-items: center; justify-content: center; height: 100%; background: #f8f9fa; border-radius: 8px;">
        <div style="text-align: center;">
            <div style="width: 40px; height: 40px; border: 4px solid #e3f2fd; border-top: 4px solid #2196f3; border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto 15px;"></div>
            <p>BioToken App wird geladen...</p>
        </div>
    </div>
    <iframe 
        id="biotoken-iframe"
        src="https://IHRE-DOMAIN.com/biotoken/"
        style="width: 100%; height: 100%; border: none; border-radius: 8px; display: none;"
        allowfullscreen>
    </iframe>
</div>

<style>
@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    var iframe = document.getElementById('biotoken-iframe');
    var loading = document.getElementById('loading');
    
    iframe.addEventListener('load', function() {
        loading.style.display = 'none';
        iframe.style.display = 'block';
    });
    
    // Fallback
    setTimeout(function() {
        loading.style.display = 'none';
        iframe.style.display = 'block';
    }, 5000);
});
</script>
```

### Schritt 3: Konfiguration
1. **Titel**: "BioToken App"
2. **Position**: Wählen Sie gewünschte Position
3. **Status**: Veröffentlicht
4. **Zugriff**: Public
5. **Speichern**

---

## 📄 **Methode 3: Direkt in Artikel einbetten**

### Schritt 1: Neuen Artikel erstellen
1. **Inhalt → Artikel → Neu**

### Schritt 2: Code einfügen
Wechseln Sie zum **HTML-Editor** und fügen Sie ein:

```html
<h2>BioToken Biodiversitäts-Tracker</h2>
<p>Entdecken Sie unsere innovative App zur Erfassung und Verwaltung von Biodiversitätsprojekten:</p>

<div style="width: 100%; height: 700px; margin: 30px 0; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
    <iframe 
        src="https://IHRE-DOMAIN.com/biotoken/"
        style="width: 100%; height: 100%; border: none;"
        allowfullscreen>
    </iframe>
</div>

<p><strong>Features:</strong></p>
<ul>
    <li>🌱 Pflanzen-Management</li>
    <li>📍 Standort-Tracking</li>
    <li>📊 Biodiversitäts-Analyse</li>
    <li>🗺️ Interaktive Karten</li>
</ul>
```

---

## ⚙️ **Deployment-Vorbereitung**

### 1. Flutter Web Build erstellen
```bash
cd /pfad/zu/biotoken
flutter build web --release
```

### 2. Dateien hochladen
Laden Sie den Inhalt von `build/web/` auf Ihren Webserver hoch:
```
webserver/
├── biotoken/
│   ├── index.html
│   ├── main.dart.js
│   ├── flutter.js
│   ├── assets/
│   └── ...
```

### 3. URL testen
Stellen Sie sicher, dass die App unter `https://ihre-domain.com/biotoken/` erreichbar ist.

---

## 🎨 **Styling-Anpassungen**

### CSS für bessere Integration
Fügen Sie zu Ihrer Joomla-Template CSS-Datei hinzu:

```css
/* BioToken App Styling */
.biotoken-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
}

.biotoken-container iframe {
    box-shadow: 0 8px 16px rgba(0,0,0,0.1);
    border-radius: 12px;
    transition: transform 0.3s ease;
}

.biotoken-container iframe:hover {
    transform: translateY(-2px);
}

/* Mobile Responsive */
@media (max-width: 768px) {
    .biotoken-container {
        padding: 10px;
    }
    
    .biotoken-container iframe {
        height: 500px !important;
        border-radius: 8px;
    }
}
```

---

## 🛠️ **Troubleshooting**

### Problem: App lädt nicht
- ✅ Überprüfen Sie die URL in den Moduleinstellungen
- ✅ Stellen Sie sicher, dass CORS richtig konfiguriert ist
- ✅ Testen Sie die App-URL direkt im Browser

### Problem: Responsive Darstellung
```css
@media (max-width: 480px) {
    .biotoken-module iframe {
        height: 400px !important;
    }
}
```

### Problem: Performance
- Verwenden Sie `loading="lazy"` für das iframe
- Implementieren Sie eine Ladeanimation
- Nutzen Sie CDN für statische Assets

---

## 📞 **Support**

Bei Fragen zur Joomla-Integration:
1. Überprüfen Sie die Joomla-Logs unter **System → Wartung → Globale Überprüfung**
2. Testen Sie in verschiedenen Browsern
3. Prüfen Sie die Browser-Konsole auf Fehler

Die BioToken-App ist jetzt erfolgreich in Ihre Joomla-Website integriert! 🎉