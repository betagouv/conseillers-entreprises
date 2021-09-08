module  Annuaire
  class UsersController < BaseController
    def index
      @antenne = @institution.antennes.find_by(id: params[:antenne_id]) # may be nil

      @users = (@antenne || @institution).advisors
        .relevant_for_skills
        .joins(:antenne)
        .order('antennes.name', 'team_name', 'users.full_name')
        .preload(:antenne, relevant_expert: [:users, :antenne, :experts_subjects])

      institutions_subjects = @institution.institutions_subjects
        .preload(:subject, :theme, :experts_subjects, :not_deleted_experts)

      @grouped_subjects = institutions_subjects
        .group_by(&:theme).transform_values{ |is| is.group_by(&:subject) }

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
  end
end
