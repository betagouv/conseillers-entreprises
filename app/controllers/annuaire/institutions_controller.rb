module  Annuaire
  class InstitutionsController < BaseController
    before_action :retrieve_institutions, only: :index
    before_action :retrieve_subjects, only: :index

    def index
      authorize Institution, :index?
      # Compteur ici pour raison de perfs
      get_antennes_count
      get_users_count
    end

    def show
      redirect_to institution_subjects_path(params[:slug])
    end

    private

    def retrieve_institutions
      @institutions = Institution.expert_provider.includes(:logo, :themes).not_deleted.order(:slug)
      @institutions = @institutions.by_region(index_search_params[:region]) if index_search_params[:region].present?
      @institutions = @institutions.joins(:themes).where(themes: { id: index_search_params[:theme] }) if index_search_params[:theme].present?
      @institutions = @institutions.joins(:subjects).where(subjects: { id: index_search_params[:subject] }) if index_search_params[:subject].present?
    end

    def get_antennes_count
      antennes_count = Antenne.select('COUNT(DISTINCT antennes.id) AS antennes_count, antennes.institution_id AS institution_id')
        .not_deleted
        .by_region(index_search_params[:region])
        .by_subject(index_search_params[:subject])
        .by_theme(index_search_params[:theme])
        .group('antennes.institution_id')

      @antennes_count = antennes_count.each_with_object({}) do |institution, hash|
        hash[institution.institution_id] = institution.antennes_count
      end
    end

    def get_users_count
      users_count = User.select('COUNT(DISTINCT users.id) AS users_count, antennes.institution_id AS institution_id')
        .joins(:antenne)
        .not_deleted
        .where(antennes: { deleted_at: nil })
        .by_region(index_search_params[:region])
        .by_subject(index_search_params[:subject])
        .by_theme(index_search_params[:theme])
        .group('antennes.institution_id')

      @users_count = users_count.each_with_object({}) do |institution, hash|
        hash[institution.institution_id] = institution.users_count
      end
    end
  end
end
