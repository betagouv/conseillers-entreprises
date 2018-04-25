# frozen_string_literal: true

class CompaniesController < ApplicationController
  def show
    siret = params[:siret]
    @facility = UseCases::SearchFacility.with_siret siret
    @company = UseCases::SearchCompany.with_siret siret
    @diagnoses = UseCases::GetDiagnoses.for_siret siret
  end

  def search; end

  def create_diagnosis_from_siret
    facility = UseCases::SearchFacility.with_siret_and_save(params[:siret])

    if facility
      visit = Visit.new(advisor: current_user, facility: facility)
      diagnosis = Diagnosis.new(visit: visit, step: '2')
    end

    if facility && visit && diagnosis.save
      redirect_to step_2_diagnosis_path(diagnosis)
    else
      render body: nil, status: :bad_request
    end
  end
end
