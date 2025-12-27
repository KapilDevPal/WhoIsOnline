module WhoIsOnline
  module ApplicationHelper
    def whoisonline_offline_script
      return unless WhoIsOnline.configuration.auto_hook

      offline_url = whoisonline_offline_path
      csrf_token = form_authenticity_token

      javascript_tag do
        <<~JS.html_safe
          (function() {
            'use strict';
            var offlineUrl = '#{offline_url}';
            var csrfToken = '#{csrf_token}';
            var isNavigating = false;

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

            document.addEventListener('click', function(e) {
              var link = e.target.closest('a');
              if (link && link.href && !link.target) {
                isNavigating = true;
              }
            }, true);

            window.addEventListener('beforeunload', markOffline);
            window.addEventListener('pagehide', markOffline);

            window.addEventListener('pageshow', function() {
              setTimeout(function() {
                isNavigating = false;
              }, 100);
            });
          })();
        JS
      end
    end
  end
end

