# frozen_string_literal: true

module Api
  class CompaniesController < ApplicationController
    def search_by_name
      companies = UseCases::SearchCompany.with_name_and_county params[:company][:name], params[:company][:county]
      render json: { companies: companies }
    end
  end
end
