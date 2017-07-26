# frozen_string_literal: true

module Api
  class FacilitiesController < ApplicationController
    def search_by_siret
      facility = UseCases::SearchFacility.with_siret params[:siret]
      company = UseCases::SearchCompany.with_siret params[:siret]

      company_name = ApiEntrepriseService.company_name(company)
      facility_location = ApiEntrepriseService.facility_location(facility.dig('etablissement'))

      render json: { company_name: company_name, facility_location: facility_location }
    end
  end
end
