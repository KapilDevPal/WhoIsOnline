module WhoIsOnline
  module ApplicationHelper
    def whoisonline_offline_script
      return unless WhoIsOnline.configuration.auto_hook

      offline_url = whoisonline_offline_path
      heartbeat_url = whoisonline_heartbeat_path
      csrf_token = form_authenticity_token
      interval_ms = WhoIsOnline.configuration.heartbeat_interval.to_i * 1000

      javascript_tag do
        <<~JS.html_safe
          (function() {
            'use strict';
            var offlineUrl = '#{offline_url}';
            var heartbeatUrl = '#{heartbeat_url}';
            var csrfToken = '#{csrf_token}';
            var intervalMs = #{interval_ms};
            var timer = null;
            var isNavigating = false;

            function post(url, keepalive) {
              try {
                return fetch(url, {
                  method: "POST",
                  headers: {
                    "X-Requested-With": "XMLHttpRequest",
                    "X-CSRF-Token": csrfToken,
                    "Content-Type": "application/x-www-form-urlencoded"
                  },
                  body: "authenticity_token=" + encodeURIComponent(csrfToken),
                  keepalive: !!keepalive
                });
              } catch(e) {
                return;
              }
            }

            function heartbeat() {
              if (document.hidden || isNavigating) return;
              post(heartbeatUrl, true);
            }

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

            function startHeartbeat() {
              if (timer) return;
              heartbeat();
              timer = setInterval(heartbeat, intervalMs);
            }

            function stopHeartbeat() {
              if (timer) {
                clearInterval(timer);
                timer = null;
              }
            }

            document.addEventListener('visibilitychange', function() {
              if (document.hidden) {
                stopHeartbeat();
                markOffline();
              } else {
                startHeartbeat();
              }
            });

            document.addEventListener('click', function(e) {
              var link = e.target.closest('a');
              if (link && link.href && !link.target) {
                isNavigating = true;
              }
            }, true);

            window.addEventListener('beforeunload', function() {
              stopHeartbeat();
              markOffline();
            });
            window.addEventListener('pagehide', function() {
              stopHeartbeat();
              markOffline();
            });

            window.addEventListener('pageshow', function() {
              setTimeout(function() {
                isNavigating = false;
              }, 100);
            });

            if (!document.hidden) startHeartbeat();
          })();
        JS
      end
    end
  end
end

