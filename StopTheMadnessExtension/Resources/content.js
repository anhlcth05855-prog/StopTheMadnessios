/**
 * StopTheMadness Pro - Safari Web Extension Content Script
 * Chạy trực tiếp tại "document_start" trên mọi URL (<all_urls>)
 */
(function() {
    'use strict';

    if (window.__stopTheMadnessLoaded) return;
    window.__stopTheMadnessLoaded = true;

    // Cấu hình mặc định (sẽ được đồng bộ từ native app nếu có)
    let settings = {
        masterEnabled: true,
        restoreInteractions: true,
        protectClipboard: true,
        allowZoom: true,
        blockTrackers: true,
        bypassAmp: true,
        unshortenLinks: true,
        blockAutoplay: true,
        backgroundAudio: true,
        removeAnnoyances: true,
        customCss: '',
        customJs: ''
    };

    // Giao tiếp với Safari Extension Handler để lấy cấu hình từ App Group
    const browserAPI = (typeof browser !== 'undefined') ? browser : (typeof chrome !== 'undefined' ? chrome : null);

    if (browserAPI && browserAPI.runtime && browserAPI.runtime.sendMessage) {
        try {
            browserAPI.runtime.sendMessage({
                action: "getSettings",
                url: window.location.href,
                host: window.location.hostname
            }, function(response) {
                if (response && !browserAPI.runtime.lastError) {
                    Object.assign(settings, response);
                    applyCustomRules();
                }
            });
        } catch (e) {
            console.debug('[StopTheMadness] Message to extension handler ignored:', e);
        }
    }

    /* =========================================================================
     * MODULE 1: KHÔI PHỤC TƯƠNG TÁC (INTERACTION RESTORATION)
     * ========================================================================= */
    if (settings.restoreInteractions) {
        // 1.1 Khôi phục copy, cut, paste, text selection, drag-and-drop, contextmenu
        const blockedEvents = [
            'copy', 'cut', 'paste',
            'selectstart', 'selectionchange',
            'contextmenu', 'dragstart'
        ];

        blockedEvents.forEach(eventType => {
            window.addEventListener(eventType, function(event) {
                // Ngăn trang web chặn thao tác mặc định
                event.stopImmediatePropagation();
            }, true);
        });

        // Xóa thuộc tính inline event handlers gây ức chế
        const cleanInlineHandlers = function(target) {
            if (!target) return;
            const handlers = [
                'onselectstart', 'oncontextmenu', 'oncopy', 'oncut',
                'onpaste', 'ondragstart', 'onmousedown', 'onmouseup'
            ];
            handlers.forEach(h => {
                if (target[h] !== null && typeof target[h] === 'function') {
                    try { target[h] = null; } catch (_) {}
                }
            });
        };

        cleanInlineHandlers(document);
        cleanInlineHandlers(document.documentElement);
        cleanInlineHandlers(document.body);

        const interactionObserver = new MutationObserver(mutations => {
            for (let i = 0; i < mutations.length; i++) {
                const mutation = mutations[i];
                if (mutation.type === 'childList') {
                    mutation.addedNodes.forEach(node => {
                        if (node.nodeType === 1) { // Element node
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

        // 1.2 Ngăn trang web ghi đè Clipboard (Anti Clipboard Hijacking)
        if (settings.protectClipboard && navigator.clipboard && navigator.clipboard.writeText) {
            const originalWriteText = navigator.clipboard.writeText.bind(navigator.clipboard);
            navigator.clipboard.writeText = function(text) {
                // Không cho phép trang web tự ý ghi đè clipboard khi người dùng chưa kích hoạt
                if (!window.__userInteracted) {
                    console.warn('[StopTheMadness] Blocked background clipboard hijack attempt.');
                    return Promise.reject(new DOMException('Blocked by StopTheMadness', 'NotAllowedError'));
                }
                return originalWriteText(text);
            };
        }

        // 1.3 Mở khóa thu phóng (Pinch-to-Zoom restoration)
        if (settings.allowZoom) {
            const unlockZoom = function() {
                const viewports = document.querySelectorAll('meta[name="viewport"]');
                viewports.forEach(vp => {
                    let content = vp.getAttribute('content') || '';
                    if (content.includes('user-scalable=no') ||
                        content.includes('user-scalable=0') ||
                        content.includes('maximum-scale=1')) {

                        let updated = content
                            .replace(/user-scalable\s*=\s*(no|0)/gi, 'user-scalable=yes')
                            .replace(/maximum-scale\s*=\s*[0-9.]+/gi, 'maximum-scale=5.0')
                            .replace(/minimum-scale\s*=\s*[0-9.]+/gi, 'minimum-scale=0.25');

                        vp.setAttribute('content', updated);
                    }
                });
            };

            unlockZoom();
            window.addEventListener('DOMContentLoaded', unlockZoom);
        }
    }

    /* =========================================================================
     * MODULE 2: CHẶN THEO DÕI & DỌN SẠCH URL (TRACKER BLOCKING & URL SANITIZER)
     * ========================================================================= */
    const TRACKING_QUERY_PARAMS = [
        'utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content', 'utm_id',
        'fbclid', 'gclid', 'gbraid', 'wbraid', 'msclkid', 'mc_eid', 'igshid', 'si',
        '_ga', '_gl', 'yclid', 'trk', 'ref', 'ref_src', 'ref_url', 'mkt_tok',
        'twclid', 'pd_rd_r', 'pd_rd_w', 'pd_rd_wg', 'pf_rd_r', 'pf_rd_p'
    ];

    function cleanUrl(rawUrl) {
        if (!rawUrl || typeof rawUrl !== 'string') return rawUrl;
        try {
            const urlObj = new URL(rawUrl, window.location.href);

            // 2.1 Loại bỏ toàn bộ tracking query params
            TRACKING_QUERY_PARAMS.forEach(param => {
                if (urlObj.searchParams.has(param)) {
                    urlObj.searchParams.delete(param);
                }
            });

            // 2.2 Giải mã Unwrap Redirect (google.com/url, facebook.com/l.php, out.reddit.com)
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
        } catch (_) {
            return rawUrl;
        }
    }

    if (settings.blockTrackers) {
        // Chặn theo dõi qua siêu liên kết (Hyperlink Auditing - ping attribute)
        document.addEventListener('click', function(event) {
            const link = event.target.closest('a');
            if (!link) return;

            if (link.hasAttribute('ping')) {
                link.removeAttribute('ping');
            }

            const href = link.getAttribute('href');
            if (href && !href.startsWith('#') && !href.startsWith('javascript:')) {
                const cleaned = cleanUrl(href);
                if (cleaned !== href) {
                    link.setAttribute('href', cleaned);
                }
            }
        }, true);

        // 2.3 Tự động chuyển hướng Google AMP / CDN AMP về Canonical URL gốc
        if (settings.bypassAmp) {
            const checkAndRedirectAmp = function() {
                const isGoogleAmp = location.hostname.includes('google.') && location.pathname.includes('/amp/');
                const isCdnAmp = location.hostname.endsWith('.ampproject.org');

                if (isGoogleAmp || isCdnAmp) {
                    const canonical = document.querySelector('link[rel="canonical"]');
                    if (canonical && canonical.href && canonical.href !== location.href) {
                        window.location.replace(canonical.href);
                    }
                }
            };

            checkAndRedirectAmp();
            window.addEventListener('DOMContentLoaded', checkAndRedirectAmp);
        }
    }

    /* =========================================================================
     * MODULE 3: KIỂM SOÁT VIDEO & ÂM THANH (MEDIA CONTROL & BACKGROUND PLAYBACK)
     * ========================================================================= */
    // Nhận diện tương tác thực sự của người dùng
    window.__userInteracted = false;
    ['pointerdown', 'keydown', 'touchstart'].forEach(type => {
        window.addEventListener(type, () => {
            window.__userInteracted = true;
        }, { once: true, capture: true });
    });

    // 3.1 Chặn Autoplay & Ép controls = true trên toàn bộ video/audio
    const originalPlay = HTMLMediaElement.prototype.play;
    HTMLMediaElement.prototype.play = function() {
        this.controls = true;

        if (settings.blockAutoplay && !window.__userInteracted) {
            console.warn('[StopTheMadness] Autoplay prevented for media:', this.src || this.currentSrc);
            return Promise.reject(new DOMException('Autoplay blocked by StopTheMadness Pro', 'NotAllowedError'));
        }
        return originalPlay.apply(this, arguments);
    };

    function enforceControls(media) {
        if (!media) return;
        media.controls = true;
        media.removeAttribute('autoplay');
    }

    document.querySelectorAll('video, audio').forEach(enforceControls);
    new MutationObserver(mutations => {
        mutations.forEach(m => {
            m.addedNodes.forEach(node => {
                if (node.nodeType === 1) {
                    if (node.tagName === 'VIDEO' || node.tagName === 'AUDIO') {
                        enforceControls(node);
                    } else if (node.querySelectorAll) {
                        node.querySelectorAll('video, audio').forEach(enforceControls);
                    }
                }
            });
        });
    }).observe(document.documentElement || document, { childList: true, subtree: true });

    // 3.2 Ngăn Safari tắt tiếng khi tab chạy nền (Fake visibility)
    if (settings.backgroundAudio) {
        Object.defineProperty(document, 'hidden', {
            get: () => false,
            configurable: true
        });
        Object.defineProperty(document, 'visibilityState', {
            get: () => 'visible',
            configurable: true
        });
        window.addEventListener('visibilitychange', function(event) {
            event.stopImmediatePropagation();
        }, true);
    }

    /* =========================================================================
     * MODULE 4: CHẶN BANNER RÁC & POPUPS (ANNOYANCE REMOVAL)
     * ========================================================================= */
    if (settings.removeAnnoyances) {
        // 4.1 Chặn popup xin quyền Web Notification
        if (window.Notification) {
            window.Notification.requestPermission = function() {
                console.info('[StopTheMadness] Notification request blocked.');
                return Promise.resolve('denied');
            };
            Object.defineProperty(window.Notification, 'permission', {
                get: () => 'denied',
                configurable: true
            });
        }

        // 4.2 Ẩn Smart App Banners & Google One Tap
        const purgeAnnoyanceElements = function() {
            const selectors = [
                '#credential_picker_container',
                'iframe[src*="accounts.google.com/gsi/"]',
                'iframe[src*="smartlock.google.com"]',
                '.smartbanner',
                '.app-banner',
                '.mobile-app-banner',
                '[class*="AppInstallBanner"]',
                '[class*="OpenInAppModal"]',
                '[id*="google-one-tap"]',
                'div[aria-label="Get the Reddit app"]',
                '.RedditAppBanner',
                '.quora-app-banner',
                '.branch-journeys-top',
                '#branch-banner-iframe'
            ];

            selectors.forEach(sel => {
                document.querySelectorAll(sel).forEach(el => {
                    el.style.setProperty('display', 'none', 'important');
                    el.style.setProperty('visibility', 'hidden', 'important');
                    el.style.setProperty('max-height', '0px', 'important');
                });
            });
        };

        purgeAnnoyanceElements();
        window.addEventListener('DOMContentLoaded', purgeAnnoyanceElements);
        setInterval(purgeAnnoyanceElements, 1200);
    }

    /* =========================================================================
     * CUSTOM CSS & JAVASCRIPT INJECTION THEO DOMAIN
     * ========================================================================= */
    function applyCustomRules() {
        if (settings.customCss && settings.customCss.trim().length > 0) {
            const style = document.createElement('style');
            style.type = 'text/css';
            style.id = 'stm-custom-css';
            style.appendChild(document.createTextNode(settings.customCss));
            (document.head || document.documentElement).appendChild(style);
        }

        if (settings.customJs && settings.customJs.trim().length > 0) {
            try {
                const script = document.createElement('script');
                script.type = 'text/javascript';
                script.id = 'stm-custom-js';
                script.appendChild(document.createTextNode(settings.customJs));
                (document.head || document.documentElement).appendChild(script);
            } catch (err) {
                console.error('[StopTheMadness] Custom JS Execution error:', err);
            }
        }
    }

    console.log('[StopTheMadness Pro iOS Extension] Content script loaded & operational.');
})();

