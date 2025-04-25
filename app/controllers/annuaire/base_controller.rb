module Annuaire
  class BaseController < ApplicationController
    include PersistedSearch

    layout 'annuaire'

    def retrieve_institution
      @institution = Institution.find_by(slug: params[:institution_slug].presence || params[:institution])
      authorize @institution
    end

    def form_params
      %i[institution antenne name region_code theme_id subject_id]
        .reduce({}) { |h,key| h[key] = params[key]; h }
    end

    def retrieve_form_params
      params.merge(form_params)
    end

    def retrieve_subjects
      @subjects = if index_search_params[:theme_id].present?
        Theme.find_by(id: index_search_params[:theme_id]).subjects
      else
        Subject.not_archived.order(:label)
      end
    end

    private

    def search_session_key
      :annuaire_search
    end

    def search_fields
      [:region_code, :theme_id, :subject_id, :query]
    end
  end
end
