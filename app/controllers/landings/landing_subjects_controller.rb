# frozen_string_literal: true

class Landings::LandingSubjectsController < Landings::BaseController
  before_action :retrieve_landing_subject

  def show
    solicitation_params = { landing_subject: @landing_subject }.merge(retrieve_solicitation_params)
    @solicitation = @landing.solicitations.new(solicitation_params)
  end

  def create_solicitation
    sanitized_params = sanitize_params(solicitation_params).merge(retrieve_query_params)
    @solicitation = SolicitationModification::Create.new(sanitized_params).call!
    if @solicitation.persisted?
      CompanyMailer.confirmation_solicitation(@solicitation).deliver_later
      @solicitation.delay.prepare_diagnosis(nil)
    end

    render :show # rerender the form on error, render the thankyou partial on success
  end

  private

  def retrieve_landing_subject
    slug = params[:slug]
    @landing_subject = Rails.cache.fetch("landing-subject-#{slug}", expires_in: 1.minute) do
      LandingSubject.not_archived.find_by(slug: slug)
    end

    redirect_to root_path, status: :moved_permanently if @landing_subject.nil?
  end

  def solicitation_params
    params.require(:solicitation)
      .permit(:landing_id, :landing_subject_id, :description, :code_region,
              *Solicitation::FIELD_TYPES.keys)
  end

  def retrieve_query_params
    # Les params ne passent pas en session dans les iframe, raison pour laquelle on check ici aussi les params de l'url
    saved_params = session[:solicitation_form_info] || {}
    query_params = view_params.slice(*Solicitation::FORM_INFO_KEYS)
    saved_params.merge!(query_params)
    session.delete(:solicitation_form_info)
    { form_info: saved_params }
  end

  # Params envoyés dans les iframes pour pré-remplir le formulaire
  def retrieve_solicitation_params
    # On ne cherche que dans les params, car contexte d'iframe = pas de session
    query_params = view_params.slice(:siret)
    { siret: query_params['siret'] }
  end
end
