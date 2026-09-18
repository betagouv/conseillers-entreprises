module  Annuaire
  class InstitutionsController < BaseController
    before_action :retrieve_institutions, only: :index
    before_action :retrieve_subjects, only: :index

    def index
      authorize Institution, :index?
    end

    def show
      redirect_to institution_subjects_path(params[:slug])
    end

    private

    def retrieve_institutions
      @institutions = Institution
        .expert_provider
        .includes(:logo, institutions_subjects: :theme)
        .not_deleted
        .apply_filters(index_search_params)
        .order(:slug)
        .with_count(:antennes, :advisors)
    end
  end
end
