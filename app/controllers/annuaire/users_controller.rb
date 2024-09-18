module  Annuaire
  class UsersController < BaseController
    before_action :retrieve_institution
    before_action :retrieve_antenne, only: :index
    before_action :retrieve_experts_and_managers, only: :index

    before_action :retrieve_subjects, only: :index

    def index
      institutions_subjects_by_theme = @institution.institutions_subjects
        .includes(:subject, :theme, :experts_subjects, :not_deleted_experts)
        .group_by(&:theme)
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
          result = users.export_xlsx(include_expert: true, institutions_subjects: institutions_subjects_exportable)
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

    private

    def retrieve_experts_and_managers
      @grouped_experts = group_experts
      @grouped_experts.each_key do |antenne|
        managers = antenne.managers.not_deleted.without_experts
        managers.each do |manager|
          next if manager.experts.any?
          @grouped_experts[antenne][Expert.new] = [manager]
        end
      end
      retrieve_antennes_without_experts
    end

    def retrieve_antennes_without_experts
      if index_search_params[:region].present? && index_search_params[:theme].blank? && index_search_params[:subject].blank?
        antennes = @institution.antennes_in_region(index_search_params[:region]).where.missing(:experts)
      elsif index_search_params[:theme].blank? && index_search_params[:subject].blank?
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
        User.where(id: flash[:table_highlighted_ids]).where(invitation_sent_at: nil)
      else
        # Ne prend pas @experts directement pour avoir les responsables sans experts
        User.joins(:antenne).where(antennes: @grouped_experts.keys, invitation_sent_at: nil)
      end
    end

    def retrieve_antenne
      @antenne = @institution.antennes.find_by(id: params[:antenne_id]) # may be nil
      @referencement_coverages = @antenne.referencement_coverages if @antenne.present?
    end

    def filtered_experts
      base_experts
        .not_deleted
        .order('antennes.name', 'full_name')
        .preload(:antenne, :experts_subjects, :communes, :antenne, users: :user_rights_manager)
        .by_region(index_search_params[:region])
        .by_theme(index_search_params[:theme])
        .by_subject(index_search_params[:subject])
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
