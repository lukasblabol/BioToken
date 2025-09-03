<?php
/**
 * BioToken Flutter App Module for Joomla
 * @package    BioToken
 * @subpackage Modules
 * @license    GNU/GPL, see LICENSE.php
 */

// No direct access
defined('_JEXEC') or die;

// Get module parameters
$moduleclass_sfx = htmlspecialchars($params->get('moduleclass_sfx'));
$app_url = $params->get('app_url', '');
$width = $params->get('width', '100%');
$height = $params->get('height', '600px');
$show_loading = $params->get('show_loading', 1);

// Generate unique ID for this module instance
$module_id = 'biotoken-' . $module->id;
?>

<div id="<?php echo $module_id; ?>" class="biotoken-module <?php echo $moduleclass_sfx; ?>">
    <?php if ($show_loading): ?>
    <div id="<?php echo $module_id; ?>-loading" class="biotoken-loading">
        <div class="loading-spinner"></div>
        <p>BioToken App wird geladen...</p>
    </div>
    <?php endif; ?>
    
    <div id="<?php echo $module_id; ?>-container" class="biotoken-container" style="display: none;">
        <iframe 
            id="<?php echo $module_id; ?>-iframe"
            src="<?php echo htmlspecialchars($app_url); ?>"
            style="width: <?php echo htmlspecialchars($width); ?>; height: <?php echo htmlspecialchars($height); ?>; border: none; border-radius: 8px;"
            allowfullscreen
            loading="lazy">
        </iframe>
    </div>
</div>

<style>
.biotoken-module {
    position: relative;
    width: 100%;
    margin: 20px 0;
}

.biotoken-loading {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: <?php echo htmlspecialchars($height); ?>;
    background: #f8f9fa;
    border-radius: 8px;
    border: 1px solid #dee2e6;
}

.loading-spinner {
    width: 40px;
    height: 40px;
    border: 4px solid #e3f2fd;
    border-top: 4px solid #2196f3;
    border-radius: 50%;
    animation: spin 1s linear infinite;
    margin-bottom: 15px;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

.biotoken-loading p {
    color: #666;
    font-size: 14px;
    margin: 0;
}

.biotoken-container iframe {
    transition: opacity 0.3s ease;
}

/* Responsive Design */
@media (max-width: 768px) {
    .biotoken-container iframe {
        height: 500px;
    }
}

@media (max-width: 480px) {
    .biotoken-container iframe {
        height: 400px;
    }
}
</style>

<script>
(function() {
    var moduleId = '<?php echo $module_id; ?>';
    var iframe = document.getElementById(moduleId + '-iframe');
    var container = document.getElementById(moduleId + '-container');
    var loading = document.getElementById(moduleId + '-loading');
    
    if (iframe) {
        iframe.addEventListener('load', function() {
            if (loading) {
                loading.style.display = 'none';
            }
            container.style.display = 'block';
            iframe.style.opacity = '1';
        });
        
        // Fallback: Show iframe after 5 seconds even if load event doesn't fire
        setTimeout(function() {
            if (loading && loading.style.display !== 'none') {
                loading.style.display = 'none';
                container.style.display = 'block';
                iframe.style.opacity = '1';
            }
        }, 5000);
    }
})();
</script>