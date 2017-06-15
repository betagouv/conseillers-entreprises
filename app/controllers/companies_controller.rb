# frozen_string_literal: true

class CompaniesController < ApplicationController
  def index
    @queries = Search.last_queries_of_user current_user
  end

  def search
    siret = params[:company][:siret]
    UseCases::SearchCompany.with_siret_and_save siret: siret, user: current_user
    visit = Visit.find_by(siret: siret, advisor: current_user)
    if visit
      redirect_to company_visit_path visit
    else
      redirect_to new_visit_path siret: siret
    end
  end

  def search_with_name
    @firmapi_json = FirmapiService.search_companies name: params[:company][:name], county: params[:company][:county]
  end

  def show
    @visit = Visit.find params[:id]
    @company = UseCases::SearchCompany.with_siret @visit.siret
    nom_commercial = @company['entreprise']['nom_commercial']
    nom_commercial = @company['entreprise']['raison_sociale'] if nom_commercial.blank?
    @qwant_results = QwantApiService.results_for_query nom_commercial if nom_commercial.present?
    render layout: 'company'
  end
end
