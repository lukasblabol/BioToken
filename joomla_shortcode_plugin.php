<?php
/**
 * BioToken Shortcode Plugin for Joomla
 * Usage: {biotoken url="https://your-domain.com/biotoken/" width="100%" height="600px"}
 * 
 * @package    BioToken
 * @subpackage Plugins
 * @license    GNU/GPL, see LICENSE.php
 */

// No direct access
defined('_JEXEC') or die;

class PlgContentBiotoken extends JPlugin
{
    /**
     * Plugin method to process BioToken shortcodes
     */
    public function onContentPrepare($context, &$article, &$params, $page = 0)
    {
        // Check if the shortcode exists in the content
        if (strpos($article->text, '{biotoken') === false) {
            return true;
        }

        // Regular expression to match {biotoken} shortcodes
        $regex = '/\{biotoken\s+(.*?)\}/i';
        
        if (preg_match_all($regex, $article->text, $matches)) {
            foreach ($matches[0] as $index => $match) {
                $attributes = $this->parseAttributes($matches[1][$index]);
                $replacement = $this->generateBioTokenEmbed($attributes);
                $article->text = str_replace($match, $replacement, $article->text);
            }
        }

        return true;
    }

    /**
     * Parse shortcode attributes
     */
    private function parseAttributes($attributeString)
    {
        $attributes = array(
            'url' => '',
            'width' => '100%',
            'height' => '600px',
            'loading' => 'true',
            'title' => 'BioToken App'
        );

        // Parse attributes like url="..." width="..."
        if (preg_match_all('/(\w+)=["\'](.*?)["\']/i', $attributeString, $attrMatches)) {
            foreach ($attrMatches[1] as $index => $attr) {
                $attributes[strtolower($attr)] = $attrMatches[2][$index];
            }
        }

        return $attributes;
    }

    /**
     * Generate the BioToken embed HTML
     */
    private function generateBioTokenEmbed($attributes)
    {
        $uniqueId = 'biotoken-' . uniqid();
        $showLoading = ($attributes['loading'] === 'true');
        
        $html = '<div id="' . $uniqueId . '" class="biotoken-shortcode-embed">';
        
        if ($showLoading) {
            $html .= '
            <div id="' . $uniqueId . '-loading" class="biotoken-loading" style="
                display: flex; 
                flex-direction: column; 
                align-items: center; 
                justify-content: center; 
                height: ' . htmlspecialchars($attributes['height']) . '; 
                background: #f8f9fa; 
                border-radius: 8px; 
                border: 1px solid #dee2e6;
                margin: 20px 0;
            ">
                <div style="
                    width: 40px; 
                    height: 40px; 
                    border: 4px solid #e3f2fd; 
                    border-top: 4px solid #2196f3; 
                    border-radius: 50%; 
                    animation: biotoken-spin 1s linear infinite; 
                    margin-bottom: 15px;
                "></div>
                <p style="color: #666; font-size: 14px; margin: 0;">
                    ' . htmlspecialchars($attributes['title']) . ' wird geladen...
                </p>
            </div>';
        }
        
        $html .= '
        <div id="' . $uniqueId . '-container" class="biotoken-container" style="display: ' . ($showLoading ? 'none' : 'block') . '; margin: 20px 0;">
            <iframe 
                id="' . $uniqueId . '-iframe"
                src="' . htmlspecialchars($attributes['url']) . '"
                title="' . htmlspecialchars($attributes['title']) . '"
                style="
                    width: ' . htmlspecialchars($attributes['width']) . '; 
                    height: ' . htmlspecialchars($attributes['height']) . '; 
                    border: none; 
                    border-radius: 8px;
                    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
                "
                allowfullscreen
                loading="lazy">
                <p>Ihr Browser unterstützt keine iFrames. 
                   <a href="' . htmlspecialchars($attributes['url']) . '" target="_blank">
                   Öffnen Sie die BioToken App hier</a>.
                </p>
            </iframe>
        </div>
        </div>';
        
        // Add JavaScript for loading behavior
        if ($showLoading) {
            $html .= '
            <script>
            (function() {
                var iframe = document.getElementById("' . $uniqueId . '-iframe");
                var container = document.getElementById("' . $uniqueId . '-container");
                var loading = document.getElementById("' . $uniqueId . '-loading");
                
                if (iframe && container && loading) {
                    iframe.addEventListener("load", function() {
                        loading.style.display = "none";
                        container.style.display = "block";
                    });
                    
                    // Fallback: Show iframe after 5 seconds
                    setTimeout(function() {
                        if (loading.style.display !== "none") {
                            loading.style.display = "none";
                            container.style.display = "block";
                        }
                    }, 5000);
                }
            })();
            </script>';
        }
        
        // Add CSS animation
        $html .= '
        <style>
        @keyframes biotoken-spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .biotoken-shortcode-embed iframe {
            transition: transform 0.3s ease;
        }
        
        .biotoken-shortcode-embed iframe:hover {
            transform: translateY(-2px);
        }
        
        @media (max-width: 768px) {
            .biotoken-shortcode-embed iframe {
                height: 500px !important;
            }
        }
        
        @media (max-width: 480px) {
            .biotoken-shortcode-embed iframe {
                height: 400px !important;
            }
        }
        </style>';
        
        return $html;
    }
}