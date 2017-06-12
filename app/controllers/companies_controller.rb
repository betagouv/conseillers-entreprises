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
    @company = ApiEntreprise::Company.from_siret params[:siret]
    if @company.blank?
      render :no_results, layout: 'company'
    else
      @qwant_results = QwantApiService.results_for_query nom_commercial if nom_commercial.present?
      render layout: 'company'
    end
  end

  private

  def nom_commercial
    nom_commercial = @company.entreprise.nom_commercial
    nom_commercial.present? ? nom_commercial : @company.entreprise.raison_sociale
  end
end
