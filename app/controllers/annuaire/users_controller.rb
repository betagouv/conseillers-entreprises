module  Annuaire
  class UsersController < BaseController
    before_action :retrieve_institution
    before_action :retrieve_antenne, only: :index
    before_action :retrieve_users, only: :index

    def index
      institutions_subjects_by_theme = @institution.institutions_subjects
        .includes(:subject, :theme, :experts_subjects, :not_deleted_experts)
        .group_by(&:theme)
      institutions_subjects_exportable = institutions_subjects_by_theme.values.flatten

      @grouped_subjects = institutions_subjects_by_theme.transform_values{ |is| is.group_by(&:subject) }
      @grouped_users = @users.select(:antennes).group_by(&:antenne).transform_values{ |users| users.group_by(&:relevant_expert) }

      @not_invited_users = not_invited_users

      respond_to do |format|
        format.html
        format.csv do
          result = @users.export_csv(include_expert_team: true, institutions_subjects: institutions_subjects_exportable)
          send_data result.csv, type: 'text/csv; charset=utf-8', disposition: "attachment; filename=#{result.filename}.csv"
        end
        format.xlsx do
          xlsx_filename = "#{(@antenne || @institution).name.parameterize}-#{@users.model_name.human.pluralize.parameterize}.xlsx"
          result = @users.export_xlsx(include_expert_team: true, institutions_subjects: institutions_subjects_exportable)
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

    def not_invited_users
      if flash[:table_highlighted_ids].present?
        User.where(id: flash[:table_highlighted_ids]).where(invitation_sent_at: nil)
      else
        @users.where(invitation_sent_at: nil)
      end
    end

    def retrieve_antenne
      @antenne = @institution.antennes.find_by(id: params[:antenne_id]) # may be nil
      @referencement_coverages = @antenne.referencement_coverages if @antenne.present?
    end

    def retrieve_users
      @users = base_users
        .relevant_for_skills
        .order('antennes.name', 'team_name', 'users.full_name')
        .preload(:antenne, :user_rights_manager, relevant_expert: [:users, :antenne, :experts_subjects, :communes])

      if params[:region_id].present?
        @users = @users.in_region(params[:region_id])
      end
    end

    def base_users
      if params[:advisor].present?
        searched_advisor = User.find(params[:advisor])
        flash[:table_highlighted_ids] = [searched_advisor.id]
        advisors = @antenne.advisors.joins(:antenne)
      elsif session[:highlighted_antennes_ids] && @antenne.nil?
        advisors = @institution.advisors.joins(:antenne).where(antenne: { id: session[:highlighted_antennes_ids] })
      else
        advisors = (@antenne || @institution).advisors.joins(:antenne)
      end
      session.delete(:highlighted_antennes_ids)
      advisors
    end
  end
end
