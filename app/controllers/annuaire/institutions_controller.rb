module  Annuaire
  class InstitutionsController < BaseController
    before_action :retrieve_region_id, only: :index
    skip_before_action :retrieve_institution
    before_action :retrieve_institutions, only: :index

    def index
      authorize Institution, :index?
    end

    def show
      redirect_to institution_subjects_path(params[:slug])
    end

    def clear_search
      clear_annuaire_session
      redirect_to institutions_path
    end

    private

    def retrieve_institutions
      @institutions = Institution.retrieve_institutions(session[:annuaire_region_id])
    end
  end
end
