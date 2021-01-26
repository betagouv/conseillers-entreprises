# frozen_string_literal: true

module IframePrefix
  extend ActiveSupport::Concern
  # Allow the routes of a controller to be served inside an iframe.
  # Features:
  # * the adopting controller can be served both in an iframe or regularly
  # * the views can now if they’re being rendered within an iframe
  # * links from the iframe keep working within the iframe,
  #   * only if the target url can be rendered in the iframe.
  #
  # See also:
  # * routes.rb: The controller must be scoped, like that:
  #   `scope path: "(:iframe_prefix)", iframe_prefix: /my_nice_prefix?/, defaults: {iframe_prefix: nil}`
  # * iframe_external_links.js: The <a href=''> links in the page are automatically tweaked to target the iframe.
  included do
    helper OverrideUrlFor # Insert our implementation in the helpers stack to customize url_for.

    prepend_before_action :detect_iframe_prefix

    skip_forgery_protection if: -> { in_iframe? }
    after_action :allow_in_iframe, if: -> { in_iframe? }
  end

  def detect_iframe_prefix
    params
    # Implementation Note: A side-effect of calling params is to make sure @iframe_prefix is set.
  end

  def params
    clean_params = super
    # Note: :iframe_prefix is the name of the optional parameter defined in routes.rb.
    @iframe_prefix ||= clean_params.delete(:iframe_prefix)
    # Implementation Note: clean_params actually points to an instance variable of a superclass, which we’re modifying.
    # It means that on the second call, clean_params doesn’t contain :iframe_prefix anymore.
    clean_params
  end

  def allow_in_iframe
    # Note: ActionDispatch sets "X-Frame-Options" => "SAMEORIGIN" by default,
    # which prevents a page to be displayed in an iframe.
    response.headers.except! 'X-Frame-Options'
  end

  # Implementation Note:
  # We want in_iframe? to be available both in template (as a helper method) and in controllers.
  # The InIframe module is included in SharedController…
  module InIframe
    extend ActiveSupport::Concern
    included { helper_method :in_iframe? } # … and this makes the in_iframe? method available in all views.

    def in_iframe?
      @iframe_prefix.present?
    end
  end

  # We also override :url_for so that links to iframe-compatible routes are correctly routed.
  # i.e., `link_to landing_page` returns normally a link to `/aide-entreprises/<slug>`,
  # and instead this makes it return `/<iframe_prefix>/aide-entreprises/<slug>`.
  #
  # Note: See also iframe_external_links.js for the
  module OverrideUrlFor
    # :url_for is called, via :link_to or the `*_path` helpers, in the view templates.
    def url_for(args)
      prefix_url_if_needed(super)
    end

    private

    # We want iframe-compatible local urls to open _inside_ the iframe,
    # and we want to include the prefix automatically.
    def prefix_url_if_needed(raw_url)
      return raw_url unless in_iframe?

      # Avoid prefixing urls to other sites.
      url = URI.parse(raw_url)
      is_local_url = url.hostname.blank? ||
        url.hostname == default_url_options[:host] && url.port == default_url_options[:port]
      return raw_url unless is_local_url

      # Only prefix urls to routes compatible with iframes
      controller = Rails.application.routes.recognize_path(url.path)[:controller]
      klass = (controller.camelize + 'Controller').constantize
      return raw_url unless klass <= IframePrefix

      url.path = "/#{@iframe_prefix}" + url.path
      url.to_s
    end
  end
end
