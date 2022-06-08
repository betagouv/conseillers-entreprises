module Annuaire
  class BaseController < ApplicationController
    before_action :retrieve_form_params, except: :search
    layout 'annuaire'

    def retrieve_institution
      @institution = Institution.find_by(slug: params[:institution_slug].presence || params[:by_institution])
      authorize @institution
    end

    def form_params
      %i[by_institution by_antenne by_name by_region]
        .reduce({}) { |h,key| h[key] = params[key]; h }
    end

    def retrieve_form_params
      params.merge(form_params)
    end
  end
end
