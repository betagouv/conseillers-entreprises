# frozen_string_literal: true

module IframePrefix
  extend ActiveSupport::Concern
  included do
    prepend_before_action :detect_landing_presence
    skip_forgery_protection if: -> { in_iframe? }
    after_action :allow_in_iframe, if: -> { in_iframe? }
  end

  # Pour s'assurer que in_iframe? fonctionne en toutes circonstances
  def detect_landing_presence
    @landing ||= Landing.find_by(slug: params[:landing_slug])
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
    included { helper_method :in_iframe?, :show_breadcrumbs? } # … and this makes the in_iframe? method available in all views.

    def in_iframe?
      defined?(@landing) && @landing.iframe?
    end

    def show_breadcrumbs?
      !in_iframe? || (in_iframe? && defined?(@landing) && @landing.layout_multiple_steps? && !@landing.subjects_iframe?)
    end
  end

  # We also override :url_for so that links to iframe-compatible routes are correctly routed.
  # i.e., `link_to landing_page` returns normally a link to `/aide-entreprises/<slug>`,
  # and instead this makes it return `/<iframe_prefix>/aide-entreprises/<slug>`.
  #
  # Note: See also iframe_external_links.js for the
  module OverrideUrlFor
    # :url_for is called, via :link_to or the `*_path` helpers, in the view templates.
    # def url_for(args)
    #   prefix_url_if_needed(super)
    # end

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
