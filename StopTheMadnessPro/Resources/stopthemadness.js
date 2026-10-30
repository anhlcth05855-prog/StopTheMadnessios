/**
 * StopTheMadness Pro Engine for iOS & Safari
 * Injected into every page to restore web freedom, privacy & media control.
 */
(function() {
    'use strict';

    if (window.__stopTheMadnessLoaded) return;
    window.__stopTheMadnessLoaded = true;

    // Default configuration (can be updated dynamically)
    const config = {
        restoreInteractions: true,
        blockTrackers: true,
        controlVideoAudio: true,
        removeAnnoyances: true,
        blockAutoplay: true,
        backgroundAudio: true,
        allowZoom: true,
        protectClipboard: true
    };

    function notifyNative(action, payload) {
        try {
            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.StopTheMadnessBridge) {
                window.webkit.messageHandlers.StopTheMadnessBridge.postMessage({ action: action, data: payload || {} });
            } else if (window.StopTheMadnessBridge && typeof window.StopTheMadnessBridge.postMessage === 'function') {
                window.StopTheMadnessBridge.postMessage(JSON.stringify({ action: action, data: payload || {} }));
            }
        } catch (e) {
            console.warn('[StopTheMadness] bridge notification error', e);
        }
    }

    /* =========================================================================
     * 1. KHÔI PHỤC QUYỀN TƯƠNG TÁC (INTERACTION RESTORATION)
     * ========================================================================= */
    if (config.restoreInteractions) {
        // Prevent websites from disabling copy, selection, contextmenu, drag
        const blockedEvents = ['selectstart', 'selectionchange', 'copy', 'cut', 'contextmenu', 'dragstart'];

        blockedEvents.forEach(eventType => {
            window.addEventListener(eventType, function(e) {
                e.stopImmediatePropagation = function() {};
                e.stopPropagation = function() {};
            }, true);
        });

        // Clean inline handlers blocking interaction
        function cleanInlineHandlers(el) {
            if (!el) return;
            const handlers = ['onselectstart', 'oncontextmenu', 'oncopy', 'oncut', 'ondragstart', 'onmousedown', 'onmouseup'];
            handlers.forEach(h => {
                if (el[h] !== null && typeof el[h] === 'function') {
                    try { el[h] = null; } catch(err) {}
                }
            });
        }

        cleanInlineHandlers(document);
        cleanInlineHandlers(document.body);
        cleanInlineHandlers(document.documentElement);

        const interactionObserver = new MutationObserver(mutations => {
            for (let mutation of mutations) {
                if (mutation.type === 'childList') {
                    mutation.addedNodes.forEach(node => {
                        if (node.nodeType === 1) {
                            cleanInlineHandlers(node);
                        }
                    });
                }
            }
        });

        interactionObserver.observe(document.documentElement || document, {
            childList: true,
            subtree: true
        });

        // Anti Clipboard Hijacking
        if (config.protectClipboard && navigator.clipboard && navigator.clipboard.writeText) {
            const originalWriteText = navigator.clipboard.writeText.bind(navigator.clipboard);
            navigator.clipboard.writeText = function(text) {
                notifyNative('clipboardWrite', { text: text ? text.substring(0, 100) : '' });
                return originalWriteText(text);
            };
        }

        // Anti Pinch-to-zoom lock: Fix viewport meta tag
        if (config.allowZoom) {
            function unlockZoom() {
                const viewports = document.querySelectorAll('meta[name="viewport"]');
                viewports.forEach(vp => {
                    let content = vp.getAttribute('content') || '';
                    if (content.includes('user-scalable=no') || content.includes('maximum-scale=1') || content.includes('user-scalable=0')) {
                        let newContent = content
                            .replace(/user-scalable\s*=\s*(no|0)/gi, 'user-scalable=yes')
                            .replace(/maximum-scale\s*=\s*[0-9.]+/gi, 'maximum-scale=5.0')
                            .replace(/minimum-scale\s*=\s*[0-9.]+/gi, 'minimum-scale=0.25');
                        vp.setAttribute('content', newContent);
                        notifyNative('zoomRestored', { original: content, updated: newContent });
                    }
                });
            }

            unlockZoom();
            window.addEventListener('DOMContentLoaded', unlockZoom);
        }

        // Scroll lock removal
        function unlockScroll() {
            if (document.documentElement) {
                const htmlStyle = window.getComputedStyle(document.documentElement);
                if (htmlStyle.overflow === 'hidden' && !document.querySelector('.stm-modal-open')) {
                    document.documentElement.style.setProperty('overflow', 'auto', 'important');
                }
            }
            if (document.body) {
                const bodyStyle = window.getComputedStyle(document.body);
                if (bodyStyle.overflow === 'hidden' && !document.querySelector('.stm-modal-open')) {
                    document.body.style.setProperty('overflow', 'auto', 'important');
                }
            }
        }
        window.addEventListener('load', unlockScroll);
    }

    /* =========================================================================
     * 2. CHẶN THEO DÕI & DỌN SẠCH URL (TRACKER BLOCKING & URL CLEANING)
     * ========================================================================= */
    const TRACKING_PARAMS = [
        'utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content', 'utm_id',
        'fbclid', 'gclid', 'gbraid', 'wbraid', 'msclkid', 'mc_eid', 'igshid', 'si',
        '_ga', '_gl', 'yclid', 'trk', 'ref', 'ref_src', 'ref_url', 'mkt_tok',
        'vgo_ee', 'vero_id', 'wickedid', 'twclid', 'pd_rd_r', 'pd_rd_w', 'pd_rd_wg', 'pf_rd_r', 'pf_rd_p'
    ];

    function cleanUrl(rawUrl) {
        try {
            const urlObj = new URL(rawUrl, window.location.href);
            let cleaned = false;

            TRACKING_PARAMS.forEach(param => {
                if (urlObj.searchParams.has(param)) {
                    urlObj.searchParams.delete(param);
                    cleaned = true;
                }
            });

            // Decode unwrapped redirect links
            if (urlObj.hostname.includes('google.') && urlObj.pathname === '/url' && urlObj.searchParams.has('q')) {
                return urlObj.searchParams.get('q');
            }
            if (urlObj.hostname.includes('facebook.com') && urlObj.pathname.includes('/l.php') && urlObj.searchParams.has('u')) {
                return urlObj.searchParams.get('u');
            }
            if (urlObj.hostname.includes('out.reddit.com') && urlObj.searchParams.has('url')) {
                return urlObj.searchParams.get('url');
            }

            return urlObj.toString();
        } catch(e) {
            return rawUrl;
        }
    }

    if (config.blockTrackers) {
        // Intercept clicks on links
        document.addEventListener('click', function(e) {
            const target = e.target.closest('a');
            if (!target) return;

            // Remove ping attribute
            if (target.hasAttribute('ping')) {
                target.removeAttribute('ping');
            }

            const href = target.getAttribute('href');
            if (href && !href.startsWith('#') && !href.startsWith('javascript:')) {
                const cleaned = cleanUrl(href);
                if (cleaned !== href) {
                    target.setAttribute('href', cleaned);
                    notifyNative('trackerRemoved', { original: href, cleaned: cleaned });
                }
            }
        }, true);

        // Google AMP Detection & Canonical redirection
        function checkAmp() {
            const isAmpHost = location.hostname.includes('google.') && location.pathname.includes('/amp/');
            const isCdnAmp = location.hostname.endsWith('.ampproject.org');
            
            if (isAmpHost || isCdnAmp) {
                const canonicalLink = document.querySelector('link[rel="canonical"]');
                if (canonicalLink && canonicalLink.href && canonicalLink.href !== location.href) {
                    notifyNative('ampDetected', { canonical: canonicalLink.href });
                }
            }
        }
        window.addEventListener('DOMContentLoaded', checkAmp);
    }

    /* =========================================================================
     * 3. KIỂM SOÁT VIDEO & ÂM THANH (VIDEO & AUDIO CONTROL)
     * ========================================================================= */
    if (config.controlVideoAudio) {
        // Background audio playback: Fake document.visibilityState and hidden
        if (config.backgroundAudio) {
            Object.defineProperty(document, 'hidden', {
                get: function() { return false; },
                configurable: true
            });
            Object.defineProperty(document, 'visibilityState', {
                get: function() { return 'visible'; },
                configurable: true
            });
            window.addEventListener('visibilitychange', function(e) {
                e.stopImmediatePropagation();
            }, true);
        }

        // Intercept HTMLMediaElement play for Autoplay blocking & native controls
        const origPlay = HTMLMediaElement.prototype.play;
        HTMLMediaElement.prototype.play = function() {
            this.controls = true;

            if (config.blockAutoplay && !window.__userInteracted) {
                notifyNative('autoplayBlocked', { src: this.currentSrc || this.src });
                return Promise.reject(new DOMException('StopTheMadness prevented autoplay', 'NotAllowedError'));
            }
            return origPlay.apply(this, arguments);
        };

        // Track user gesture
        ['pointerdown', 'keydown', 'touchstart'].forEach(evt => {
            window.addEventListener(evt, () => {
                window.__userInteracted = true;
            }, { once: true, capture: true });
        });

        // Ensure controls on existing and new videos
        function enforceVideoControls(media) {
            if (media.tagName === 'VIDEO' || media.tagName === 'AUDIO') {
                media.controls = true;
                media.removeAttribute('autoplay');
            }
        }

        document.querySelectorAll('video, audio').forEach(enforceVideoControls);
        new MutationObserver(mutations => {
            mutations.forEach(m => {
                m.addedNodes.forEach(node => {
                    if (node.nodeType === 1) {
                        if (node.tagName === 'VIDEO' || node.tagName === 'AUDIO') {
                            enforceVideoControls(node);
                        } else if (node.querySelectorAll) {
                            node.querySelectorAll('video, audio').forEach(enforceVideoControls);
                        }
                    }
                });
            });
        }).observe(document.documentElement || document, { childList: true, subtree: true });
    }

    /* =========================================================================
     * 4. LOẠI BỎ THÔNG BÁO LÀM PHIỀN (ANNOYANCE REMOVAL)
     * ========================================================================= */
    if (config.removeAnnoyances) {
        // Block Web Push Notification Prompts
        if (window.Notification) {
            window.Notification.requestPermission = function() {
                notifyNative('notificationBlocked', {});
                return Promise.resolve('denied');
            };
            Object.defineProperty(window.Notification, 'permission', {
                get: function() { return 'denied'; },
                configurable: true
            });
        }

        // Hide Google One Tap sign-in prompt & App Install banners
        function removeAnnoyanceElements() {
            const selectors = [
                '#credential_picker_container',
                'iframe[src*="accounts.google.com/gsi/"]',
                'iframe[src*="smartlock.google.com"]',
                '.smartbanner',
                '.app-banner',
                'div[id*="google-one-tap"]',
                'div[aria-label="Get the Reddit app"]',
                'div[class*="AppInstallBanner"]',
                'div[class*="OpenInAppModal"]',
                'div[class*="mobile-app-banner"]',
                'div[id*="branch-banner"]',
                'div[class*="FullPageModal__overlay"]'
            ];
            
            selectors.forEach(sel => {
                document.querySelectorAll(sel).forEach(el => {
                    el.style.setProperty('display', 'none', 'important');
                    el.style.setProperty('visibility', 'hidden', 'important');
                });
            });
        }

        window.addEventListener('DOMContentLoaded', removeAnnoyanceElements);
        setInterval(removeAnnoyanceElements, 1500);
    }

    console.log('[StopTheMadness Pro iOS] Engine initialized successfully.');
})();

