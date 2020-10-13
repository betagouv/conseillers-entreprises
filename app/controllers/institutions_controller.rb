class InstitutionsController < ApplicationController
  before_action :retrieve_institution, except: :index

  layout 'side_menu', except: :index

  def index
    authorize Institution, :index?

    @institutions = Institution.all
      .order(:slug)
      .preload([institutions_subjects: :theme], :not_deleted_antennes, :not_deleted_advisors)

    @wide_layout = true
  end

  def show
    redirect_to action: :subjects
  end

  def subjects
  end

  def antennes
    respond_to do |format|
      format.html
      format.csv do
        result = @antennes.export_csv
        send_data result.csv, type: 'text/csv; charset=utf-8', disposition: "attachment; filename=#{result.filename}.csv"
      end
    end
  end

  def advisors
    respond_to do |format|
      format.html
      format.csv do
        result = @advisors.export_csv(institutions_subjects: @institutions_subjects)
        send_data result.csv, type: 'text/csv; charset=utf-8', disposition: "attachment; filename=#{result.filename}.csv"
      end
    end
  end

  def import_antennes
  end

  def import_antennes_create
    @result = Antenne.import_csv(params.require(:file), institution: @institution)
    if @result.success?
      flash[:table_highlighted_ids] = @result.objects.map(&:id)
      redirect_to action: :antennes
    else
      render :import_antennes
    end
  end

  def import_advisors; end

  def import_advisors_create
    @result = User.import_csv(params.require(:file), institution: @institution)
    if @result.success?
      flash[:table_highlighted_ids] = @result.objects.map(&:id)
      redirect_to action: :advisors
    else
      render :import_advisors
    end
  end

  private

  def retrieve_institution
    @institution = Institution.find_by(slug: params[:slug])
    authorize @institution

    @institutions_subjects = @institution.institutions_subjects
      .ordered_for_interview
      .preload(:subject, :theme, :experts_subjects, :not_deleted_experts)

    @antennes = @institution.antennes
      .not_deleted
      .order(:name)
      .preload(:communes)

    @advisors = @institution.advisors
      .not_deleted
      .relevant_for_skills
      .joins(:antenne)
      .order('antennes.name', 'team_name', 'users.full_name')
      .preload(:antenne, relevant_expert: [:not_deleted_users, :antenne, :experts_subjects])
  end
end
