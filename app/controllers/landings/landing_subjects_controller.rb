# frozen_string_literal: true

class Landings::LandingSubjectsController < Landings::BaseController
  before_action :retrieve_landing_subject

  def show
    @solicitation = @landing.solicitations.new(landing_subject: @landing_subject)
  end

  def create_solicitation
    sanitized_params = sanitize_params(solicitation_params).merge(retrieve_form_info)
    @solicitation = SolicitationModification::Create.call(sanitized_params)
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
      LandingSubject.find_by(slug: slug)
    end

    redirect_to root_path, status: :moved_permanently if @landing_subject.nil?
  end

  def solicitation_params
    params.require(:solicitation)
      .permit(:landing_id, :landing_subject_id, :description, :code_region,
              *Solicitation::FIELD_TYPES.keys)
  end

  def show_params
    params.permit(:slug, *Solicitation::FORM_INFO_KEYS)
  end

  def save_form_info
    form_info = session[:solicitation_form_info] || {}
    info_params = show_params.slice(*Solicitation::FORM_INFO_KEYS)
    form_info.merge!(info_params)
    session[:solicitation_form_info] = form_info if form_info.present?
  end

  def retrieve_form_info
    # Les params ne passent pas en session dans les iframe, raison pour laquelle on check ici aussi les params de l'url
    form_info = session[:solicitation_form_info] || {}
    info_params = show_params.slice(*Solicitation::FORM_INFO_KEYS)
    form_info.merge!(info_params)
    session.delete(:solicitation_form_info)
    { form_info: form_info }
  end
end
