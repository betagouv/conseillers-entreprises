# frozen_string_literal: true

class CompaniesController < ApplicationController
  def search_by_siret
    company = UseCases::SearchCompany.with_siret params[:siret]
    @company_name = ApiEntrepriseService.company_name(company)
    location_hash = company['etablissement_siege']['commune_implantation']
    @company_location = "#{location_hash['code']} #{location_hash['value']}" if location_hash
  end

  def search_by_name
    @firmapi_json = FirmapiService.search_companies name: params[:company][:name], county: params[:company][:county]
  end

  def show
    @visit = Visit.find params[:id]
    @company = UseCases::SearchCompany.with_siret @visit.company.siren
    nom_commercial = ApiEntrepriseService.company_name(@company)
    @qwant_results = QwantApiService.results_for_query nom_commercial if nom_commercial.present?
    render layout: 'company'
  end
end
