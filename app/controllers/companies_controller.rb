# frozen_string_literal: true

class CompaniesController < ApplicationController
  def search
    @query = search_query
    if @query.present?
      siret = siret(@query)
      if siret.present? && luhn(siret)
        redirect_to company_path(siret, query: @query)
      else
        search_results
      end
    end
  end

  def show
    siret = params[:siret]
    query = params[:query]
    @facility = UseCases::SearchFacility.with_siret siret
    @company = UseCases::SearchCompany.with_siret siret
    @diagnoses = UseCases::GetDiagnoses.for_siret siret
    save_search(query, @company.name)
  end

  def create_diagnosis_from_siret
    facility = UseCases::SearchFacility.with_siret_and_save(params[:siret])

    if facility
      visit = Visit.new(advisor: current_user, facility: facility)
      diagnosis = Diagnosis.new(visit: visit, step: '2')
    end

    if diagnosis&.save
      redirect_to step_2_diagnosis_path(diagnosis)
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

  def siret(query)
    maybe_siret = query.gsub(/\s+/, '')
    maybe_siret if maybe_siret.match?(/\d{14}/)
  end

  def luhn(str)
    s = str.reverse
    sum = 0
    tmp = 0
    (0..s.size-1).step(2) do |k| # k is odd, k+1 is even
      sum += s[k].to_i           #s1
      tmp = s[k+1].to_i * 2
      if tmp > 9
        tmp = tmp.to_s.split(//).map(&:to_i).reduce(:+)
      end
      sum += tmp
    end
    (sum%10).zero?
  end

  def save_search(query, label = nil)
    Search.create user: current_user, query: query, label: label
  end
end
