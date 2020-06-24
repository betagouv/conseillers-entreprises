# frozen_string_literal: true

module IframePrefix
  extend ActiveSupport::Concern
  # Allow the routes of a controller to be served inside an optional iframe,
  # with working navigation inside the iframe.
  # The routes for the controller must be scoped, like that:
  # scope path: "(:iframe_prefix)", iframe_prefix: /my_nice_prefix?/, defaults: {iframe_prefix: nil}
  included do
    helper OverrideUrlFor # Insert our implementation in the helpers stack to customize url_for.

    prepend_before_action :detect_iframe_prefix

    skip_forgery_protection if: -> { in_iframe? }
    after_action :allow_in_iframe, if: -> { in_iframe? }
  end

  def detect_iframe_prefix
    params # side-effect: Make sure @iframe_prefix is set.
  end

  def params
    clean_params = super
    @iframe_prefix ||= clean_params.delete(:iframe_prefix)
    clean_params
  end

  def allow_in_iframe
    response.headers.except! 'X-Frame-Options'
  end

  # We want in_iframe? to be available both in template (as a helper method) and in controllers
  module InIframe
    extend ActiveSupport::Concern
    included { helper_method :in_iframe? }

    def in_iframe?
      @iframe_prefix.present?
    end
  end

  # Override :url_for
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
      return raw_url unless klass.ancestors.include?(IframePrefix)

      url.path = "/#{@iframe_prefix}" + url.path
      url.to_s
    end
  end
end
