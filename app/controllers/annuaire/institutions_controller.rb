module  Annuaire
  class InstitutionsController < BaseController
    before_action :retrieve_institutions, only: :index

    def index
      authorize Institution, :index?
      get_antennes_count
      get_users_count
      # if params[:region_id].present?
      #   get_antennes_count
      #   get_users_count
      # end
    end

    def show
      redirect_to institution_subjects_path(params[:slug])
    end

    private

    def retrieve_institutions
      @institutions = Institution.retrieve_institutions(params[:region_id])
    end

    def get_antennes_count
      antennes_count = Antenne.select('COUNT(DISTINCT antennes.id) AS antennes_count, antennes.institution_id AS institution_id')
        .left_joins(:regions, :experts)
        .not_deleted
        # .where(territories: { id: params[:region_id] })
        .or(Antenne.where(experts: { is_global_zone: true }).where(deleted_at: nil))
        .group('antennes.institution_id')

      antennes_count = antennes_count.where(territories: { id: params[:region_id] }) if params[:region_id].present?

      @antennes_count = antennes_count.each_with_object({}) do |institution, hash|
        hash[institution.institution_id] = institution.antennes_count
      end
    end

    def get_users_count
      users_count = User.select('COUNT(DISTINCT users.id) AS users_count, antennes.institution_id AS institution_id')
        .not_deleted
        .left_joins(:antenne_regions, :experts)
        # .where(antennes: { territories: { id: params[:region_id] } })
        .or(Antenne.where(experts: { is_global_zone: true }).where(users: { deleted_at: nil }))
        .group('antennes.institution_id')

      users_count = users_count.where(antennes: { territories: { id: params[:region_id] } }) if params[:region_id].present?

      @users_count = users_count.each_with_object({}) do |institution, hash|
        hash[institution.institution_id] = institution.users_count
      end
    end
  end
end
