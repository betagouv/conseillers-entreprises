# frozen_string_literal: true

class CompaniesController < ApplicationController
  def index; end

  def search
    Search.create! user: current_user, query: params[:company][:siret]
    redirect_to company_path(params[:company][:siret])
  end

  def show
    @company = ApiEntrepriseService.fetch_company_with_siret params[:siret]
  end
end
