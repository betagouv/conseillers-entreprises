# frozen_string_literal: true

class CompaniesController < ApplicationController
  def show
    siret = params[:siret]
    @facility = UseCases::SearchFacility.with_siret siret
    @company = UseCases::SearchCompany.with_siret siret
    @qwant_results = QwantApiService.results_for_query @company.name
    associations = [diagnosed_needs: :selected_assistance_experts, visit: :advisor]
    @diagnoses = Diagnosis.completed.includes(associations).of_siret(siret)
    @diagnoses = Diagnosis.enrich_with_diagnosed_needs_count(@diagnoses)
    @diagnoses = Diagnosis.enrich_with_selected_assistances_experts_count(@diagnoses)
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
