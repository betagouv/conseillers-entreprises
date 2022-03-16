# frozen_string_literal: true

class CompaniesController < ApplicationController
  def search
    @query = search_query
    @current_solicitation = get_current_solicitation
    if @query.present?
      siret = FormatSiret.siret_from_query(@query)
      if siret.present?
        redirect_to company_path(siret, solicitation: @current_solicitation&.id)
      else
        search_results
      end
    end
  end

  def show
    @diagnosis = DiagnosisCreation.new_diagnosis
    facility = Facility.find(params.permit(:id)[:id])

    search_facility_informations(facility.siret)
  end

  def show_with_siret
    current_solicitation = get_current_solicitation
    @diagnosis = DiagnosisCreation.new_diagnosis(current_solicitation)

    siret = params.permit(:siret)[:siret]
    clean_siret = FormatSiret.clean_siret(siret)
    if clean_siret != siret
      redirect_to show_with_siret_companies_path(clean_siret, solicitation: current_solicitation&.id)
      return
    end

    search_facility_informations(siret)
    save_search(siret, @company.name)

    render :show
  end

  def needs
    ## TODO : afficher aussi les besoins déposés avec le même email (cf cas cession/reprise)
    @facility = Facility.find(params.permit(:id)[:id])
    @needs_in_progress = NeedInProgressPolicy::Scope.new(current_user, @facility.needs).resolve
    @needs_done = NeedDonePolicy::Scope.new(current_user, @facility.needs).resolve
  end

  private

  def search_facility_informations(siret)
    begin
      @facility = ApiConsumption::Facility.new(siret).call
      company_and_siege = ApiConsumption::CompanyAndSiege.new(siret[0,9]).call
      @company = company_and_siege.company
      @siege_facility = company_and_siege.siege_facility
    rescue ApiEntreprise::ApiEntrepriseError => e
      message = I18n.t("api_entreprise.generic_error")
      redirect_back fallback_location: { action: :search }, alert: message
      return
    end
  end

  def search_results
    response = ApiSirene::FullTextSearch.search(@query)
    if response.success?
      @etablissements = response.etablissements
      @suggestions = response.suggestions
    else
      flash.now.alert = response.error_message || I18n.t('companies.search.generic_error')
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
