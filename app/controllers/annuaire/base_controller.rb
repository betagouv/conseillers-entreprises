module Annuaire
  class BaseController < ApplicationController
    before_action :retrieve_institution
    layout 'annuaire'

    def retrieve_institution
      @institution = Institution.find_by(slug: params[:institution_slug])
      authorize @institution
    end

    def retrieve_region_id
      @region_id = params.permit(:region_id)[:region_id] || session[:annuaire_region_id]
      session[:annuaire_region_id] = @region_id
    end

    def clear_annuaire_session
      session.delete(:annuaire_region_id)
    end
  end
end
