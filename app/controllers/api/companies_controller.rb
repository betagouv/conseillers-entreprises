# frozen_string_literal: true

module Api
  class CompaniesController < ApplicationController
    def search_by_siret
      company = UseCases::SearchCompany.with_siret params[:siret]
      company_name = ApiEntrepriseService.company_name(company)
      location_hash = company['etablissement_siege']['commune_implantation']
      company_location = location_hash ? "#{location_hash['code']} #{location_hash['value']}" : ''
      render json: { company_name: company_name, company_location: company_location }
    end
  end
end
