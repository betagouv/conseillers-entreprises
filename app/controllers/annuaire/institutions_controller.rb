module  Annuaire
  class InstitutionsController < BaseController
    before_action :retrieve_institutions, only: :index

    def index
      authorize Institution, :index?
    end

    def show
      redirect_to institution_subjects_path(params[:slug])
    end

    private

    def retrieve_institutions
      @institutions = Institution.retrieve_institutions(params[:region_id])
    end
  end
end
