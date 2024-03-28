module Annuaire
  class BaseController < ApplicationController
    before_action :set_session_params
    before_action :retrieve_form_params, except: :search
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

    def set_session_params
      if params[:reset_query].present?
        form_params.each_key do |key|
          session.delete("annuaire_#{key}")
        end
      else
        form_params.each_key do |key|
          session["annuaire_#{key}"] = params[key].presence if params.key?(key.to_s)
        end
      end
    end

    def retrieve_subjects
      @subjects = if session[:annuaire_theme].present?
        Theme.find_by(id: session[:annuaire_theme]).subjects
      else
        Subject.not_archived.order(:label)
      end
    end
  end
end
