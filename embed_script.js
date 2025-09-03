/**
 * BioToken App Embedding Script
 * Dieses Skript ermöglicht es, die BioToken Flutter-App in bestehende Webseiten einzubetten
 */

class BioTokenEmbed {
  constructor(options = {}) {
    this.options = {
      // Standard-Konfiguration
      containerId: options.containerId || 'biotoken-app',
      width: options.width || '100%',
      height: options.height || '600px',
      baseUrl: options.baseUrl || 'https://your-domain.com/biotoken', // ANPASSEN!
      showBorder: options.showBorder !== false,
      borderRadius: options.borderRadius || '8px',
      boxShadow: options.boxShadow || '0 4px 12px rgba(0,0,0,0.15)',
      backgroundColor: options.backgroundColor || '#ffffff',
      
      // Erweiterte Optionen
      allowFullscreen: options.allowFullscreen !== false,
      sandbox: options.sandbox || 'allow-scripts allow-same-origin allow-popups allow-forms',
      loading: options.loading || 'lazy',
      
      // Callback-Funktionen
      onLoad: options.onLoad || null,
      onError: options.onError || null,
      onMessage: options.onMessage || null
    };
    
    this.iframe = null;
    this.container = null;
  }

  /**
   * Hauptfunktion zum Einbetten der App
   */
  embed() {
    try {
      // Container finden oder erstellen
      this.container = document.getElementById(this.options.containerId);
      if (!this.container) {
        console.error(`Container mit ID '${this.options.containerId}' nicht gefunden!`);
        return false;
      }

      // iFrame erstellen
      this.iframe = document.createElement('iframe');
      this.setupIframe();
      this.setupStyles();
      this.setupEventListeners();

      // iFrame zum Container hinzufügen
      this.container.appendChild(this.iframe);
      
      console.log('BioToken App erfolgreich eingebettet');
      return true;
    } catch (error) {
      console.error('Fehler beim Einbetten der BioToken App:', error);
      if (this.options.onError) {
        this.options.onError(error);
      }
      return false;
    }
  }

  /**
   * iFrame-Eigenschaften konfigurieren
   */
  setupIframe() {
    this.iframe.src = this.options.baseUrl;
    this.iframe.width = '100%';
    this.iframe.height = '100%';
    this.iframe.frameBorder = '0';
    this.iframe.loading = this.options.loading;
    
    if (this.options.allowFullscreen) {
      this.iframe.allowFullscreen = true;
    }
    
    if (this.options.sandbox) {
      this.iframe.sandbox = this.options.sandbox;
    }

    // Accessibility
    this.iframe.title = 'BioToken Biodiversitäts-App';
    this.iframe.setAttribute('role', 'application');
  }

  /**
   * Container-Styling anwenden
   */
  setupStyles() {
    const containerStyle = {
      width: this.options.width,
      height: this.options.height,
      backgroundColor: this.options.backgroundColor,
      position: 'relative',
      overflow: 'hidden'
    };

    if (this.options.showBorder) {
      containerStyle.borderRadius = this.options.borderRadius;
      containerStyle.boxShadow = this.options.boxShadow;
    }

    Object.assign(this.container.style, containerStyle);
    
    // iFrame-Styling
    this.iframe.style.border = 'none';
    this.iframe.style.display = 'block';
  }

  /**
   * Event-Listener einrichten
   */
  setupEventListeners() {
    // Load-Event
    this.iframe.addEventListener('load', () => {
      console.log('BioToken App geladen');
      if (this.options.onLoad) {
        this.options.onLoad(this.iframe);
      }
    });

    // Error-Event
    this.iframe.addEventListener('error', (error) => {
      console.error('Fehler beim Laden der BioToken App:', error);
      this.showErrorMessage();
      if (this.options.onError) {
        this.options.onError(error);
      }
    });

    // PostMessage-Event für Kommunikation
    window.addEventListener('message', (event) => {
      if (event.origin === new URL(this.options.baseUrl).origin) {
        if (this.options.onMessage) {
          this.options.onMessage(event.data);
        }
      }
    });

    // Responsive Handling
    window.addEventListener('resize', () => {
      this.handleResize();
    });
  }

  /**
   * Fehlerbehandlung mit Nutzer-Feedback
   */
  showErrorMessage() {
    const errorDiv = document.createElement('div');
    errorDiv.innerHTML = `
      <div style="
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        height: 100%;
        background: #f8f9fa;
        color: #6c757d;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        text-align: center;
        padding: 40px;
      ">
        <div style="font-size: 48px; margin-bottom: 16px;">🌱</div>
        <h3 style="margin: 0 0 8px 0; color: #495057;">BioToken App konnte nicht geladen werden</h3>
        <p style="margin: 0; font-size: 14px;">Bitte versuchen Sie es später erneut oder kontaktieren Sie den Support.</p>
        <button onclick="location.reload()" style="
          margin-top: 20px;
          padding: 8px 16px;
          background: #28a745;
          color: white;
          border: none;
          border-radius: 4px;
          cursor: pointer;
        ">Seite neu laden</button>
      </div>
    `;
    
    this.container.innerHTML = '';
    this.container.appendChild(errorDiv);
  }

  /**
   * Responsive Verhalten
   */
  handleResize() {
    if (this.iframe && this.container) {
      // Hier können responsive Anpassungen vorgenommen werden
      const containerWidth = this.container.offsetWidth;
      if (containerWidth < 768) {
        // Mobile Anpassungen
        this.container.style.height = '500px';
      }
    }
  }

  /**
   * App entfernen
   */
  destroy() {
    if (this.iframe) {
      this.iframe.remove();
      this.iframe = null;
    }
    if (this.container) {
      this.container.innerHTML = '';
    }
    console.log('BioToken App entfernt');
  }

  /**
   * Nachrichten an die App senden
   */
  sendMessage(message) {
    if (this.iframe && this.iframe.contentWindow) {
      this.iframe.contentWindow.postMessage(message, this.options.baseUrl);
    }
  }
}

// Globale Funktion für einfache Nutzung
window.BioTokenEmbed = BioTokenEmbed;

// Auto-Embedding falls data-Attribute vorhanden sind
document.addEventListener('DOMContentLoaded', function() {
  const autoEmbedElements = document.querySelectorAll('[data-biotoken-embed]');
  
  autoEmbedElements.forEach(element => {
    const options = {
      containerId: element.id,
      baseUrl: element.dataset.biotokenUrl || 'https://your-domain.com/biotoken',
      width: element.dataset.biotokenWidth || '100%',
      height: element.dataset.biotokenHeight || '600px'
    };
    
    const embedInstance = new BioTokenEmbed(options);
    embedInstance.embed();
  });
});