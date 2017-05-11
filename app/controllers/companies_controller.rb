# frozen_string_literal: true

class CompaniesController < ApplicationController
  def index; end

  def search
    @company = ApiEntrepriseService.fetch_company_with_siret params[:company][:siret]
    label = @company['entreprise']['nom_commercial'] if @company['entreprise']
    Search.create! user: current_user, query: params[:company][:siret], label: label
  end

  def show
    @company = Company.find params[:id]
  end
end
