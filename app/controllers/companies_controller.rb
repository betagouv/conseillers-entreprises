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
    @siret = params[:siret]
    @facility = UseCases::SearchFacility.with_siret @siret
    @company = UseCases::SearchCompany.with_siret @siret
    @company_name = ApiEntrepriseService.company_name @company
    @qwant_results = QwantApiService.results_for_query @company_name
    associations = [{ diagnosis: [diagnosed_needs: [:selected_assistance_experts]] }, :advisor]
    @visits = Visit.includes(associations).of_siret(@siret).with_completed_diagnosis
    render layout: 'company'
  end
  # rubocop:enable Metrics/AbcSize

  def create_diagnosis_from_siret
    facility = UseCases::SearchFacility.with_siret_and_save params[:siret]
    visit = Visit.create advisor: current_user, facility: facility if facility
    diagnosis = Diagnosis.new visit: visit, step: '2' if visit
    if facility && visit && diagnosis.save
      redirect_to step_2_diagnosis_path(diagnosis)
    else
      render body: nil, status: :bad_request
    end
  end
end
