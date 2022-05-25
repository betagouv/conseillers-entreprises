# frozen_string_literal: true

module IframePrefix
  extend ActiveSupport::Concern
  included do
    prepend_before_action :retrieve_main_objects
    skip_forgery_protection if: -> { in_iframe? }
    after_action :allow_in_iframe, if: -> { in_iframe? }
  end

  # Pour s'assurer que in_iframe? fonctionne en toutes circonstances
  # Besoin d'identifier @landing sur toutes les pages du process
  def retrieve_main_objects
    # Controller Landing & LandingTheme
    landing_slug = params[:landing_slug]
    if landing_slug.present?
      @landing = Landing.not_archived.find_by(slug: landing_slug)
      redirect_to root_path, status: :moved_permanently if @landing.nil?
    end
    # Controller Solicitation#new & create
    landing_id = params[:landing_id] || params.dig(:solicitation, :landing_id)
    if landing_id.present?
      @landing = Landing.not_archived.find(landing_id)
      redirect_to root_path, status: :moved_permanently if @landing.nil?
    end
    landing_subject_id = params[:landing_subject_id] || params.dig(:solicitation, :landing_subject_id)
    if landing_subject_id.present?
      @landing_subject = LandingSubject.not_archived.find(landing_subject_id)
      redirect_to root_path, status: :moved_permanently if @landing_subject.nil?
    end
    # Controller Solicitation#other_methods
    solicitation_uuid = params[:uuid]
    if solicitation_uuid.present?
      @solicitation ||= Solicitation.find_by(uuid: solicitation_uuid)
      redirect_to root_path if @solicitation.nil?
      @landing = @solicitation.landing
      @landing_subject = @solicitation.landing_subject
    end
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
