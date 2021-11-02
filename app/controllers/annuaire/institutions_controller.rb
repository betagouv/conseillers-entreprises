module  Annuaire
  class InstitutionsController < BaseController
    skip_before_action :retrieve_institution
    before_action :retrieve_institutions, only: %i[index search]
    before_action :retrieve_region_id, only: :search

    def index
      redirect_to search_institutions_path if session[:annuaire_region_id].present?
      authorize Institution, :index?
    end

    def show
      redirect_to institution_subjects_path(params[:slug])
    end

    def search
      @institutions = @institutions.in_region(@region_id)
      render :index
    end

    def clear_search
      clear_annuaire_session
      redirect_to institutions_path
    end

    private

    def retrieve_institutions
      @institutions = Institution.not_deleted
        .order(:slug)
        .preload([institutions_subjects: :theme], :not_deleted_antennes, :advisors)
    end
  end
end
