# frozen_string_literal: true

class CompaniesController < ApplicationController
  before_action :maybe_review_expert_subjects

  def search
    @query = search_query
    if @query.present?
      siret = Facility::siret_from_query(@query)
      if siret.present?
        redirect_to company_path(siret)
      else
        search_results
      end
    end
  end

  def show
    siret = params[:siret]
    clean_siret = Facility::clean_siret(siret)
    if clean_siret != siret
      redirect_to company_path(clean_siret)
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
    existing_facility = Facility.find_by(siret: siret)
    if existing_facility.present?
      @diagnoses = Facility.find_by(siret: siret).diagnoses
        .completed
        .includes(:matches, :advisor, :needs)
    else
      @diagnoses = Diagnosis.none
    end
    save_search(siret, @company.name)
  end

  def create_diagnosis_from_siret
    facility = UseCases::SearchFacility.with_siret_and_save(params[:siret])

    if facility
      diagnosis = Diagnosis.new(advisor: current_user, facility: facility, step: :besoins)
    end

    if diagnosis&.save
      redirect_to besoins_diagnosis_path(diagnosis)
    else
      render body: nil, status: :bad_request
    end
  end

  private

  def search_results
    response = SireneApi::SireneSearch.search(@query)
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
end
