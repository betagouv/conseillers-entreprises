# frozen_string_literal: true

class CompaniesController < ApplicationController
  def index
    @queries = Search.last_queries_of_user current_user
  end

  def search
    siret = params[:company][:siret]
    UseCases::SearchCompany.with_siret_and_save siret: siret, user: current_user
    if Visit.exists?(siret: siret, advisor: current_user)
      redirect_to company_path siret
    else
      redirect_to new_visit_path siret: siret
    end
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
