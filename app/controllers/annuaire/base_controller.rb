module Annuaire
  class BaseController < ApplicationController
    include PersistedSearch

    # before_action :retrieve_form_params, except: :search
    layout 'annuaire'

    def retrieve_institution
      @institution = Institution.find_by(slug: params[:institution_slug].presence || params[:institution])
      authorize @institution
    end

    def form_params
      %i[institution antenne name region theme subject]
        .reduce({}) { |h,key| h[key] = params[key]; h }
    end

    def retrieve_form_params
      params.merge(form_params)
    end

    def retrieve_subjects
      @subjects = if index_search_params[:theme].present?
        Theme.find_by(id: index_search_params[:theme]).subjects
      else
        Subject.not_archived.order(:label)
      end
    end

    private

    def search_session_key
      :annuaire_search
    end

    def search_fields
      [:region, :theme, :subject, :query]
    end
  end
end
