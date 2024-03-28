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
      @institutions = @institutions.in_region(session[:annuaire_region_id]) if session[:annuaire_region_id].present?
      @institutions = @institutions.joins(:themes).where(themes: { id: session[:annuaire_theme] }) if session[:annuaire_theme].present?
      @institutions = @institutions.joins(:subjects).where(subjects: { id: session[:annuaire_subject] }) if session[:annuaire_subject].present?
    end

    def get_antennes_count
      antennes_count = Antenne.select('COUNT(DISTINCT antennes.id) AS antennes_count, antennes.institution_id AS institution_id')
        .not_deleted
        .by_region(session[:annuaire_region])
        .by_subject(session[:annuaire_subject])
        .by_theme(session[:annuaire_theme])
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
        .by_region(session[:annuaire_region])
        .by_subject(session[:annuaire_subject])
        .by_theme(session[:annuaire_theme])
        .group('antennes.institution_id')

      @users_count = users_count.each_with_object({}) do |institution, hash|
        hash[institution.institution_id] = institution.users_count
      end
    end
  end
end
