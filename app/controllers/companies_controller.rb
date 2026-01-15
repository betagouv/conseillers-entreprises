class CompaniesController < ApplicationController
  def show
    @diagnosis = DiagnosisCreation::NewDiagnosis.new.call
    facility = Facility.find(params.permit(:id)[:id])

    search_facility_informations(facility.siret)
    if defined? @message
      redirect_back_or_to root_path, alert: @message
    end
  end

  def show_with_siret
    current_solicitation = get_current_solicitation
    @diagnosis = DiagnosisCreation::NewDiagnosis.new(current_solicitation).call

    siret = params.permit(:siret)[:siret]
    clean_siret = FormatSiret.clean_siret(siret)
    if clean_siret == siret
      search_facility_informations(siret)
      if @message.present?
        flash[:alert] = @message
        redirect_back_or_to root_path, alert: @message
      else
        render :show
      end
    else
      redirect_to show_with_siret_companies_path(clean_siret, solicitation: current_solicitation&.id)
    end
  end

  def needs
    @facility = authorize Facility.find(params.permit(:id)[:id])

    @needs_in_progress = policy_scope(@facility.needs)
      .in_progress
      .order(created_at: :desc)
    @needs_done = policy_scope(@facility.needs)
      .done
      .order(created_at: :desc)

    email_needs = Need.for_emails(@facility.company.contacts.pluck(:email))

    @contact_needs_in_progress = policy_scope(email_needs)
      .in_progress
      .excluding(@needs_in_progress)
      .order(created_at: :desc)
    @contact_needs_done = policy_scope(email_needs)
      .done
      .excluding(@needs_done)
      .order(created_at: :desc)
  end

  private

  def search_facility_informations(siret)
    begin
      @facility = ApiConsumption::Facility.new(siret).call
      @company = ApiConsumption::Company.new(siret[0,9]).call
      unless @facility.siege_social
        @siege_facility = ApiConsumption::Facility.new(@company.siret_siege_social).call
      end
    rescue Api::BasicError => e
      @message = e.message || I18n.t("api_requests.generic_error")
    rescue Api::TechnicalError => e
      @message = I18n.t("api_requests.technical_error", api: e.api)
    rescue StandardError => e
      Sentry.capture_message(e)
      @message = I18n.t("api_requests.generic_error")
    end
  end

  def get_current_solicitation
    Solicitation.find(params.permit(:solicitation).require(:solicitation)) if params[:solicitation].present?
  end
end
