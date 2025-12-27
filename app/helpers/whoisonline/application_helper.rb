module WhoIsOnline
  module ApplicationHelper
    def whoisonline_offline_script
      return unless WhoIsOnline.configuration.activity_only

      offline_url = whoisonline_offline_path
      heartbeat_url = whoisonline_heartbeat_path
      csrf_token = form_authenticity_token
      heartbeat_interval = (WhoIsOnline.configuration.heartbeat_interval.to_i * 1000) || 30000

      javascript_tag do
        <<~JS.html_safe
          (function() {
            'use strict';
            var offlineUrl = '#{offline_url}';
            var heartbeatUrl = '#{heartbeat_url}';
            var csrfToken = '#{csrf_token}';
            var heartbeatInterval = #{heartbeat_interval};
            var heartbeatTimer = null;
            var isPageVisible = true;
            var isNavigating = false;

            // Check if page is visible using Page Visibility API
            function isVisible() {
              if (typeof document.hidden !== 'undefined') {
                return !document.hidden;
              }
              if (typeof document.webkitHidden !== 'undefined') {
                return !document.webkitHidden;
              }
              if (typeof document.mozHidden !== 'undefined') {
                return !document.mozHidden;
              }
              return true; // Fallback: assume visible
            }

            // Send heartbeat to keep user online
            function sendHeartbeat() {
              if (!isPageVisible || isNavigating) return;

              if (navigator.sendBeacon) {
                var formData = new FormData();
                formData.append('authenticity_token', csrfToken);
                navigator.sendBeacon(heartbeatUrl, formData);
              } else {
                var xhr = new XMLHttpRequest();
                xhr.open('POST', heartbeatUrl, true);
                xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
                xhr.setRequestHeader('X-CSRF-Token', csrfToken);
                xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                xhr.send('authenticity_token=' + encodeURIComponent(csrfToken));
              }
            }

            // Mark user offline
            function markOffline() {
              if (isNavigating) return;
              
              if (navigator.sendBeacon) {
                var formData = new FormData();
                formData.append('authenticity_token', csrfToken);
                navigator.sendBeacon(offlineUrl, formData);
              } else {
                try {
                  var xhr = new XMLHttpRequest();
                  xhr.open('POST', offlineUrl, false);
                  xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
                  xhr.setRequestHeader('X-CSRF-Token', csrfToken);
                  xhr.send('authenticity_token=' + encodeURIComponent(csrfToken));
                } catch(e) {
                  // Ignore errors during page unload
                }
              }
            }

            // Start/stop heartbeat based on page visibility
            function handleVisibilityChange() {
              isPageVisible = isVisible();
              
              if (isPageVisible) {
                // Page became visible - start heartbeat
                sendHeartbeat(); // Send immediately
                startHeartbeat();
              } else {
                // Page became hidden - stop heartbeat and mark offline
                stopHeartbeat();
                markOffline();
              }
            }

            function startHeartbeat() {
              stopHeartbeat(); // Clear any existing timer
              heartbeatTimer = setInterval(sendHeartbeat, heartbeatInterval);
            }

            function stopHeartbeat() {
              if (heartbeatTimer) {
                clearInterval(heartbeatTimer);
                heartbeatTimer = null;
              }
            }

            // Track navigation to avoid double-triggering
            document.addEventListener('click', function(e) {
              var link = e.target.closest('a');
              if (link && link.href && !link.target) {
                isNavigating = true;
              }
            }, true);

            // Page Visibility API events
            document.addEventListener('visibilitychange', handleVisibilityChange);
            
            // Fallback for older browsers
            window.addEventListener('focus', function() {
              isPageVisible = true;
              sendHeartbeat();
              startHeartbeat();
            });
            
            window.addEventListener('blur', function() {
              isPageVisible = false;
              stopHeartbeat();
              markOffline();
            });

            // Mark offline on page unload
            window.addEventListener('beforeunload', function() {
              stopHeartbeat();
              markOffline();
            });
            
            window.addEventListener('pagehide', function() {
              stopHeartbeat();
              markOffline();
            });

            // Reset navigation flag and start heartbeat when page shows
            window.addEventListener('pageshow', function() {
              setTimeout(function() {
                isNavigating = false;
                if (isVisible()) {
                  sendHeartbeat();
                  startHeartbeat();
                }
              }, 100);
            });

            // Start heartbeat if page is visible on load
            if (isVisible()) {
              sendHeartbeat(); // Send immediately on page load
              startHeartbeat();
            }
          })();
        JS
      end
    end
  end
end

