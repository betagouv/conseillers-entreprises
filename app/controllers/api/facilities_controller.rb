# frozen_string_literal: true

module Api
  class FacilitiesController < ApplicationController
    def search_by_siret
      facility = UseCases::SearchFacility.with_siret params[:siret]
      company = UseCases::SearchCompany.with_siret params[:siret]
      render json: { company_name: company.name, facility_location: facility.etablissement.location }
    rescue ApiEntreprise::ApiEntrepriseError
      render body: nil, status: :unprocessable_entity
    end

    def search_by_siren
      company = UseCases::SearchCompany.with_siren params[:siren]
      render json: {
        company_name: company.name,
        facility_location: company.etablissement_siege.location,
        siret: company.etablissement_siege.siret
      }
    rescue ApiEntreprise::ApiEntrepriseError
      render body: nil, status: :unprocessable_entity
    end
  end
end
