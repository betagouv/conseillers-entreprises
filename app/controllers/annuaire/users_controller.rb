module  Annuaire
  class UsersController < BaseController
    before_action :retrieve_antenne, only: %i[index search]
    before_action :retrieve_users, only: %i[index search]
    before_action :retrieve_region_id, only: :search

    def index
      redirect_to search_institution_users_path(@institution) if session[:annuaire_region_id].present? && @antenne.nil?

      group_subjects

      xlsx_filename = "#{(@antenne || @institution).name.parameterize}-#{@users.model_name.human.pluralize.parameterize}.xlsx"

      respond_to do |format|
        format.html
        format.csv do
          result = @users.export_csv(include_expert_team: true, institutions_subjects: institutions_subjects)
          send_data result.csv, type: 'text/csv; charset=utf-8', disposition: "attachment; filename=#{result.filename}.csv"
        end
        format.xlsx do
          result = @users.export_xlsx(include_expert_team: true, institutions_subjects: institutions_subjects)
          send_data result.xlsx, type: "application/xlsx", filename: xlsx_filename
        end
      end
    end

    def search
      @users = @users.in_region(@region_id)

      group_subjects

      render :index
    end

    def clear_search
      clear_annuaire_session
      if params[:antenne].present?
        redirect_to institution_antenne_users_path(@institution, params[:antenne])
      else
        redirect_to institution_users_path(@institution)
      end
    end

    def import; end

    def import_create
      @result = User.import_csv(params.require(:file), institution: @institution)
      if @result.success?
        flash[:table_highlighted_ids] = @result.objects.map(&:id)
        flash[:highlighted_antennes_ids] = Antenne.where(advisors: @result.objects).ids
        redirect_to action: :index
      else
        render :import
      end
    end

    private

    def retrieve_antenne
      @antenne = @institution.antennes.find_by(id: params[:antenne_id]) # may be nil
    end

    def retrieve_users
      @users = (@antenne || @institution).advisors
        .relevant_for_skills
        .order('antennes.name', 'team_name', 'users.full_name')
        .joins(:antenne)
        .preload(:antenne, relevant_expert: [:users, :antenne, :experts_subjects])
    end

    def group_subjects
      institutions_subjects = @institution.institutions_subjects
        .preload(:subject, :theme, :experts_subjects, :not_deleted_experts)

      @grouped_subjects = institutions_subjects
        .group_by(&:theme).transform_values{ |is| is.group_by(&:subject) }
    end
  end
end
