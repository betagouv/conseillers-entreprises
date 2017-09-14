# frozen_string_literal: true

class CompaniesController < ApplicationController
  def show
    siret = params[:siret]
    @facility = UseCases::SearchFacility.with_siret siret
    @company = UseCases::SearchCompany.with_siret siret
    @qwant_results = QwantApiService.results_for_query @company.name
    @diagnoses = UseCases::GetDiagnoses.for_siret siret
  end

  def search; end

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
