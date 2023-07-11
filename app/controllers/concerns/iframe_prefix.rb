# frozen_string_literal: true

module IframePrefix
  extend ActiveSupport::Concern
  included do
    prepend_before_action :retrieve_main_objects
    skip_forgery_protection if: -> { in_iframe? }
    after_action :allow_in_iframe, if: -> { in_iframe? }
    helper_method :query_params
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
    landing_subject_slug = params[:landing_subject_slug]
    if landing_subject_slug.present?
      @landing_subject = LandingSubject.not_archived.find_by(slug: landing_subject_slug)
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

  def query_params
    # pas de session dans les iframe, on recupere les params dans l'url
    query_params = view_params.slice(*Solicitation::FORM_INFO_KEYS + [:siret] + AdditionalSubjectQuestion.pluck(:key))
    # on vide la session si on arrive d'un site externe
    if arrival_from_external_website
      session.delete(:solicitation_form_info)
      query_params = build_entreprendre_params(query_params)
    end
    session_params = session[:solicitation_form_info] || {}
    session_params.with_indifferent_access.merge!(query_params)
  end

  private

  def arrival_from_external_website
    p "arrival_from_external_website"
    p request.refere
    if request.referer.present?
      uri = URI(request.referer)
      base_url = [uri.scheme, uri.host].join('://')
      p base_url
      p ENV['HOST_NAME']
      base_url != ENV['HOST_NAME']
    else
      true
    end
  end

  def view_params
    params.permit(:landing_slug, :slug, :siret, *Solicitation::FORM_INFO_KEYS, AdditionalSubjectQuestion.pluck(:key))
  end

  def build_entreprendre_params(query_params)
    if from_entreprendre_website(query_params) && no_entreprendre_params(query_params)
      query_params[:api_calling_url] = request.referer
      fiche = request.referer&.split('/')&.last
      query_params[:mtm_kwd] = fiche if (fiche.present? && fiche.start_with?('F'))
    end
    query_params
  end

  def from_entreprendre_website(query_params)
    query_params[:mtm_campaign] == 'entreprendre' || query_params[:pk_campaign] == 'entreprendre'
  end

  def no_entreprendre_params(query_params)
    kwd = query_params[:mtm_kwd] || query_params[:pk_kwd]
    kwd.blank? || !kwd.start_with?('F') || query_params[:api_calling_url].blank?
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
