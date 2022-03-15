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
      @landing&.iframe?
    end

    def show_breadcrumbs?
      !in_iframe? || (in_iframe? && defined?(@landing) && @landing.layout_multiple_steps? && !@landing.subjects_iframe?)
    end
  end
end
