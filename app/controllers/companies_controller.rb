# frozen_string_literal: true

class CompaniesController < ApplicationController
  def search_by_siret
    company = UseCases::SearchCompany.with_siret params[:siret]
    @company_name = company['entreprise']['nom_commercial']
    @company_name = company['entreprise']['raison_sociale'] if @company_name.blank?
    location_hash = company['etablissement_siege']['commune_implantation']
    @company_location = "#{location_hash['code']} #{location_hash['value']}" if location_hash
  end

  def search_by_name
    @firmapi_json = FirmapiService.search_companies name: params[:company][:name], county: params[:company][:county]
  end

  def show
    @visit = Visit.find params[:id]
    @company = UseCases::SearchCompany.with_siret @visit.company.siren
    nom_commercial = @company['entreprise']['nom_commercial']
    nom_commercial = @company['entreprise']['raison_sociale'] if nom_commercial.blank?
    @qwant_results = QwantApiService.results_for_query nom_commercial if nom_commercial.present?
    render layout: 'company'
  end
end
