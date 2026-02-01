// noinspection JSUnresolvedReference

/**
 * ██████╗ ██╗  ██╗ █████╗ ███╗   ██╗████████╗ ██████╗ ███╗   ███╗
 * ██╔══██╗██║  ██║██╔══██╗████╗  ██║╚══██╔══╝██╔═══██╗████╗ ████║
 * ██████╔╝███████║███████║██╔██╗ ██║   ██║   ██║   ██║██╔████╔██║
 * ██╔═══╝ ██╔══██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚██╔╝██║
 * ██║     ██║  ██║██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚═╝ ██║
 * ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝
 * Copyright (c) 2025 Rıza Emre ARAS <r.emrearas@proton.me>
 */

// Asciinema Player initialization for MkDocs
// Asciinema Player is loaded from vendor/asciinema-player.min.js via main.html
// See tools/vendor-builder for vendor management
// noinspection JSUnresolvedVariable, JSUnresolvedFunction

/**
 * @typedef {Object} AsciinemaPlayer
 * @property {Function} create - Create player function
 */

/* global AsciinemaPlayer */

// Initialize Phantom modules namespace
window.PhantomModules = window.PhantomModules || {};

// Helper function to resolve cast file paths
function resolveCastFilePath(path) {
    // If path starts with / or http, return as-is (absolute path or URL)
    // noinspection HttpUrlsUsage - Support both HTTP and HTTPS for flexibility
    if (path.startsWith('/') || path.startsWith('http://') || path.startsWith('https://')) {
        return path;
    }
    
    // If path doesn't contain ../, assume it's relative to docs/assets/static/
    if (!path.includes('../')) {
        return '/assets/static/' + path;
    }
    
    // Otherwise, try to resolve relative path
    // Get current page path
    const currentPath = window.location.pathname;
    const pathParts = currentPath.split('/').filter(Boolean);
    
    // Remove filename from path
    if (pathParts[pathParts.length - 1].includes('.')) {
        pathParts.pop();
    }
    
    // Apply relative path
    const castPathParts = path.split('/');
    for (const part of castPathParts) {
        if (part === '..') {
            pathParts.pop();
        } else if (part !== '.') {
            pathParts.push(part);
        }
    }
    
    return '/' + pathParts.join('/');
}

// Helper function to get player options from element attributes
function getPlayerOptions(element) {
    return {
        cols: parseInt(element.getAttribute('data-cols')) || 100,
        rows: parseInt(element.getAttribute('data-rows')) || 30,
        autoPlay: element.getAttribute('data-autoplay') === 'true',
        preload: element.getAttribute('data-preload') !== 'false',
        loop: element.getAttribute('data-loop') === 'true',
        startAt: parseFloat(element.getAttribute('data-start-at')) || 0,
        speed: parseFloat(element.getAttribute('data-speed')) || 1,
        theme: element.getAttribute('data-theme') || 'solarized-dark',
        poster: element.getAttribute('data-poster') || 'npt:0:3',
        fit: element.getAttribute('data-fit') === 'true',
        terminalFontSize: element.getAttribute('data-font-size') || 'medium'
    };
}

// Helper function to mark pre elements to avoid badges
function markPreElementsNoBadge(element) {
    setTimeout(function() {
        const preElements = element.querySelectorAll('pre');
        preElements.forEach(function(pre) {
            pre.setAttribute('data-no-badge', 'true');
        });
    }, 100);
}

// Helper function to create and initialize Asciinema player
function createAsciinemaPlayer(element, castFile, playerOptions) {
    // Add loading state and spinner
    element.classList.add('loading');
    const spinner = document.createElement('div');
    spinner.className = 'player-spinner';
    spinner.innerHTML = '<div class="spinner-inner"></div>';
    element.appendChild(spinner);
    
    // Resolve cast file path
    const resolvedPath = resolveCastFilePath(castFile);
    
    try {
        // Use promise to handle async loading
        // noinspection JSUnresolvedVariable
        const playerPromise = AsciinemaPlayer.create(resolvedPath, element, playerOptions);
        
        // Handle player ready state
        if (playerPromise && typeof playerPromise.then === 'function') {
            playerPromise.then(function() {
                // Remove loading state
                element.classList.remove('loading');
                if (spinner.parentNode) {
                    spinner.remove();
                }
                // Mark any pre elements inside the player to avoid badges
                markPreElementsNoBadge(element);
            }).catch(function(error) {
                console.error('Failed to create Asciinema player:', error);
                element.classList.remove('loading');
                if (spinner.parentNode) {
                    spinner.remove();
                }
                element.innerHTML = '<div class="asciinema-error">Failed to load terminal recording</div>';
            });
        } else {
            // If not a promise, assume synchronous creation
            setTimeout(function() {
                element.classList.remove('loading');
                if (spinner.parentNode) {
                    spinner.remove();
                }
                // Mark any pre elements inside the player to avoid badges
                markPreElementsNoBadge(element);
            }, 500);
        }
    } catch (error) {
        console.error('Failed to create Asciinema player:', error);
        element.classList.remove('loading');
        if (spinner && spinner.parentNode) {
            spinner.remove();
        }
        element.innerHTML = '<div class="asciinema-error">Failed to load terminal recording</div>';
    }
}

// Define initialization function for lazy loading
window.PhantomModules.initAsciinema = function() {
    // Find all asciinema player elements
    const playerElements = document.querySelectorAll('.asciinema-player:not(.initialized)');
    
    playerElements.forEach(function(element) {
        const castFile = element.getAttribute('data-cast-file');
        const playerId = element.getAttribute('id') || 'player-' + Math.random().toString(36).substring(2, 11);
        
        if (!castFile) {
            console.error('No cast file specified for player element');
            return;
        }
        
        // Get player configuration
        const playerOptions = getPlayerOptions(element);
        
        // Set ID if not already set
        if (!element.id) {
            element.id = playerId;
        }
        
        // Mark as initialized
        element.classList.add('initialized');
        
        // Create player using helper function
        createAsciinemaPlayer(element, castFile, playerOptions);
    });
};

// Also support traditional loading (backward compatibility)
document.addEventListener('DOMContentLoaded', function() {
    // If AsciinemaPlayer is already loaded (non-lazy loading), initialize immediately
    if (typeof AsciinemaPlayer !== 'undefined' && !window.PhantomModules.asciinemaInitialized) {
        window.PhantomModules.asciinemaInitialized = true;
        window.PhantomModules.initAsciinema();
    }
});

// Handle dynamic content (e.g., when switching tabs)
if (typeof MutationObserver !== 'undefined') {
    // Helper function to initialize a player element
    function initializePlayer(element) {
        const castFile = element.getAttribute('data-cast-file');
        // noinspection JSUnresolvedVariable
        if (castFile && typeof AsciinemaPlayer !== 'undefined') {
            element.classList.add('initialized');
            
            // Get player configuration using the helper function
            const playerOptions = getPlayerOptions(element);
            
            // Create player using helper function
            createAsciinemaPlayer(element, castFile, playerOptions);
        }
    }
    
    const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            mutation.addedNodes.forEach(function(node) {
                if (node.nodeType === 1) { // Element node
                    const players = node.querySelectorAll ? node.querySelectorAll('.asciinema-player:not(.initialized)') : [];
                    players.forEach(initializePlayer);
                }
            });
        });
    });
    
    observer.observe(document.body, { childList: true, subtree: true });
}