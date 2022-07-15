# frozen_string_literal: true

class CompaniesController < ApplicationController
  def search
    @query = search_query
    @current_solicitation = get_current_solicitation
    if @query.present?
      siret = FormatSiret.siret_from_query(@query)
      if siret.present?
        redirect_to show_with_siret_companies_path(siret, solicitation: @current_solicitation&.id)
      else
        search_results
      end
    end
  end

  def show
    @diagnosis = DiagnosisCreation.new_diagnosis
    facility = Facility.find(params.permit(:id)[:id])

    search_facility_informations(facility.siret)
    if defined? @message
      redirect_back fallback_location: { action: :search }, alert: @message
    end
  end

  def show_with_siret
    current_solicitation = get_current_solicitation
    @diagnosis = DiagnosisCreation.new_diagnosis(current_solicitation)

    siret = params.permit(:siret)[:siret]
    clean_siret = FormatSiret.clean_siret(siret)
    if clean_siret == siret
      search_facility_informations(siret)
      if @message.present?
        flash.now[:alert] = @message
        redirect_back fallback_location: { action: :search }, alert: @message
      else
        save_search(siret, @company.name) if defined? @company
        render :show
      end
    else
      redirect_to show_with_siret_companies_path(clean_siret, solicitation: current_solicitation&.id)
    end
  end

  def needs
    @facility = Facility.find(params.permit(:id)[:id])
    @needs_in_progress = NeedInProgressPolicy::Scope.new(current_user, @facility.needs).resolve
    @needs_done = NeedDonePolicy::Scope.new(current_user, @facility.needs).resolve

    emails = @facility.company.contacts.pluck(:email).uniq
    needs = Need.for_emails_and_sirets(emails)
    @contact_needs_in_progress = NeedInProgressPolicy::Scope.new(current_user, needs.in_progress).resolve - @needs_in_progress
    @contact_needs_done = NeedDonePolicy::Scope.new(current_user, needs.done).resolve - @needs_done
  end

  private

  def search_facility_informations(siret)
    begin
      @facility = ApiConsumption::Facility.new(siret).call
      company_and_siege = ApiConsumption::CompanyAndSiege.new(siret[0,9]).call
      @company = company_and_siege.company
      @siege_facility = company_and_siege.siege_facility
    rescue ApiEntreprise::ApiEntrepriseError => e
      @message = I18n.t("api_requests.generic_error")
    end
  end

  def search_results
    result = SearchFacility.new({ query: @query }).from_full_text_or_siren
    if result[:error].blank?
      @etablissements = result[:items]
      pp @etablissements.first
    else
      flash.now.alert = result[:error] || I18n.t('companies.search.generic_error')
    end
    save_search(@query)
  end

  def search_query
    query = params['query']
    query.present? ? query.strip : nil
  end

  def save_search(query, label = nil)
    Search.create user: current_user, query: query, label: label
  end

  def get_current_solicitation
    Solicitation.find(params.permit(:solicitation).require(:solicitation)) if params[:solicitation].present?
  end
end
