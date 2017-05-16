# frozen_string_literal: true

class CompaniesController < ApplicationController
  def index
    @queries = Search.last_queries_of_user current_user
  end

  def search
    UseCases::SearchCompany.with_siret_and_save siret: params[:company][:siret], user: current_user
    redirect_to company_path params[:company][:siret]
  end

  def show
    @company = UseCases::SearchCompany.with_siret params[:siret]
    @qwant_results = QwantApiService.results_for_query @company['entreprise']['nom_commercial']
    render layout: 'company'
  end
end
