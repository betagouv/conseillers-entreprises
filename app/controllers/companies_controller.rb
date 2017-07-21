# frozen_string_literal: true

class CompaniesController < ApplicationController
  def search_by_siren
    company = UseCases::SearchCompany.with_siren params[:siren]
    @company_name = ApiEntrepriseService.company_name(company)
    @company_location = ApiEntrepriseService.company_name(company.dig('etablissement_siege'))
    @company_headquarters_siret = company['entreprise']['siret_siege_social']
  end

  def search_by_name
    @firmapi_json = FirmapiService.search_companies name: params[:company][:name], county: params[:company][:county]
  end

  def show
    @visit = Visit.find params[:id]
    @facility = UseCases::SearchFacility.with_siret @visit.facility.siret
    @company = UseCases::SearchCompany.with_siret @visit.facility.siret
    @qwant_results = QwantApiService.results_for_query @visit.company_name
    render layout: 'company'
  end
end
