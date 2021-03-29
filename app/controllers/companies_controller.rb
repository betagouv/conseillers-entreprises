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
    current_solicitation = get_current_solicitation
    @diagnosis = DiagnosisCreation.new_diagnosis(current_solicitation)

    siret = params[:siret]
    clean_siret = FormatSiret.clean_siret(siret)
    if clean_siret != siret
      redirect_to company_path(clean_siret, solicitation: current_solicitation&.id)
      return
    end

    begin
      @facility = UseCases::SearchFacility.with_siret siret
      @company = UseCases::SearchCompany.with_siret siret
    rescue ApiEntreprise::ApiEntrepriseError => e
      message = e.message.truncate(1000) # Avoid overflowing the cookie_store with alert messages.
      redirect_back fallback_location: { action: :search }, alert: message
      return
    end
    save_search(siret, @company.name)
  end

  def needs
    @facility = Facility.find_by(siret: params.permit(:siret)[:siret])
    @needs_in_progress = NeedInProgressPolicy::Scope.new(current_user, @facility.needs).resolve
    @needs_done = NeedDonePolicy::Scope.new(current_user, @facility.needs).resolve
  end

  private

  def search_results
    response = SireneApi::FullTextSearch.search(@query)
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
