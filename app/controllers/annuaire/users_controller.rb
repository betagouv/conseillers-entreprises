module  Annuaire
  class UsersController < BaseController
    before_action :retrieve_institution
    before_action :retrieve_antenne, only: [:index, :create_territorial_coverage]
    before_action :retrieve_experts_and_users, only: [:index, :create_territorial_coverage]

    before_action :retrieve_subjects, only: :index

    def index
      institutions_subjects_by_theme = @institution.institutions_subjects
        .includes(:subject, :theme, :experts_subjects, :not_deleted_experts)
        .group_by(&:theme)
        .sort_by { |theme, _| [theme.territorial_zones.present? ? 1 : 0, theme.label] }
        .to_h
      institutions_subjects_exportable = institutions_subjects_by_theme.values.flatten

      @grouped_subjects = institutions_subjects_by_theme.transform_values{ |is| is.group_by(&:subject) }
      @not_invited_users = not_invited_users

      respond_to do |format|
        format.html
        format.csv do
          result = retrieve_users.export_csv(include_expert: true, institutions_subjects: institutions_subjects_exportable)
          send_data result.csv, type: 'text/csv; charset=utf-8', disposition: "attachment; filename=#{result.filename}.csv"
        end
        format.xlsx do
          users = retrieve_users
          xlsx_filename = "#{(@antenne || @institution).name.parameterize}-#{users.model_name.human.pluralize.parameterize}.xlsx"
          result = XlsxExport::AnnuaireUserExporter.new(@grouped_experts, { relation_name: 'User', institutions_subjects: institutions_subjects_exportable }).export
          send_data result.xlsx.to_stream.read, type: "application/xlsx", filename: xlsx_filename
        end
      end
    end

    def send_invitations
      invite_count = 0
      params[:users_ids].split.each do |user_id|
        user = User.find user_id
        next if user.invitation_sent_at.present?
        user.invite!(current_user)
        invite_count += 1
      end
      if invite_count > 0
        flash[:notice] = t('.invitations_sent', count: invite_count)
      else
        flash[:alert] = t('.invitations_no_sent')
      end
      redirect_to institution_users_path(slug: params[:institution_slug])
    end

    def import; end

    def import_create
      @result = User.import_csv(params.require(:file), institution: @institution)
      if @result.success?
        flash[:table_highlighted_ids] = @result.objects.compact.map(&:id)
        session[:highlighted_antennes_ids] = Antenne.where(advisors: @result.objects).ids
        redirect_to action: :index
      else
        render :import, status: :unprocessable_entity
      end
    end

    def create_territorial_coverage
      institution_subject = InstitutionSubject.find_by(id: params[:institution_subject_id])
      coverage = Rails.cache.fetch(["coverage-service", institution_subject, @grouped_experts], expires_in: 2.minutes) do
        CreateTerritorialCoverage.new(institution_subject, @grouped_experts).call
      end
      render partial: 'annuaire/users/coverage', locals: { institution_subject: institution_subject, coverage: coverage }
    end

    private

    def retrieve_experts_and_users
      @grouped_experts = group_experts
      retrieve_antennes_without_experts if @antenne.blank?
      retrieve_managers_without_experts
      retrieve_users_without_experts
    end

    def retrieve_users_without_experts
      @grouped_experts.each_key do |antenne|
        users = User.joins('LEFT OUTER JOIN experts_users ON experts_users.user_id = users.id')
          .where(experts_users: { expert_id: nil })
          .where(antenne: antenne, deleted_at: nil)
        users.each do |user|
          next if user.managed_antennes.any?
          @grouped_experts[antenne][Expert.new] = [user]
        end
      end
    end

    def retrieve_managers_without_experts
      @grouped_experts.each_key do |antenne|
        managers_from_other_antennes = antenne.managers.not_deleted
        managers_from_other_antennes.each do |manager|
          next if manager.experts.any?
          @grouped_experts[antenne][Expert.new] = [manager]
        end
      end
    end

    def retrieve_antennes_without_experts
      # Si il y a des filtres de recherche par theme ou sujet
      # on ne prend pas les antennes sans experts pour ne pas polluer l'affichage
      if index_search_params[:region_code].present? && index_search_params[:theme_id].blank? && index_search_params[:subject_id].blank?
        antennes = @institution.antennes_in_region(index_search_params[:region_code]).where.missing(:experts)
      elsif index_search_params[:theme_id].blank? && index_search_params[:subject_id].blank?
        antennes = @institution.antennes.where.missing(:experts)
      else
        antennes = []
      end
      antennes.each do |antenne|
        @grouped_experts[antenne] = { Expert.new => antenne.advisors } if antenne.advisors.any?
      end
    end

    def not_invited_users
      if flash[:table_highlighted_ids].present?
        User.not_deleted.where(id: flash[:table_highlighted_ids]).where(invitation_sent_at: nil)
      else
        # Ne prend pas @experts directement pour avoir les responsables sans experts
        User.not_deleted.joins(:antenne).where(antenne: @grouped_experts.keys, invitation_sent_at: nil)
      end
    end

    def retrieve_antenne
      @antenne = @institution.antennes.find_by(id: params[:antenne_id]) # may be nil
    end

    def filtered_experts
      experts = base_experts
        .not_deleted
        .preload(:antenne, :experts_subjects, users: :user_rights_manager)
        .by_region(index_search_params[:region_code])
        .by_theme(index_search_params[:theme_id])
        .by_subject(index_search_params[:subject_id])

      # Re-join with antennes for ordering since some scopes might break the join
      experts.joins(:antenne)
        .select('experts.*, antennes.name as antenne_name')
        .order('antennes.name', 'experts.full_name')
    end

    def group_experts
      filtered_experts.group_by(&:antenne).transform_values do |experts|
        experts.index_with do |expert|
          expert.users.presence || [User.new]
        end
      end
    end

    def retrieve_users
      user_ids = @grouped_experts.values.flat_map(&:values).flatten.map(&:id).uniq
      User.where(id: user_ids)
    end

    def base_experts
      if params[:advisor].present?
        searched_user = User.find(params[:advisor])
        flash[:table_highlighted_ids] = [searched_user.id]
        experts = @antenne.experts.joins(:antenne)
      elsif session[:highlighted_antennes_ids] && @antenne.nil?
        users = @institution.advisors.joins(:antenne).where(antenne: { id: session[:highlighted_antennes_ids] })
        experts = Expert.joins(:antenne).where(antenne: users.map(&:antenne))
      else
        experts = (@antenne || @institution).experts.joins(:antenne)
      end
      session.delete(:highlighted_antennes_ids)
      experts
    end
  end
end
