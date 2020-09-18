class InstitutionsController < ApplicationController
  before_action :retrieve_institution, except: :index

  layout 'side_menu', except: :index

  def index
    authorize Institution, :index?

    @institutions = Institution.all
      .order(:slug)
      .preload([institutions_subjects: :theme], :antennes, :advisors)

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
        csv = CsvExportService.csv(@antennes)
        filename = CsvExportService.filename(@antennes)
        send_data csv, type: 'text/csv; charset=utf-8', disposition: "filename=#{filename}.csv"
      end
    end
  end

  def advisors
    respond_to do |format|
      format.html
      format.csv do
        additional_fields = User.csv_fields_for_relevant_expert_team
          .merge(User.csv_fields_for_relevant_expert_subjects(@institutions_subjects))
        csv = CsvExportService.csv(@advisors, additional_fields)
        filename = CsvExportService.filename(@advisors)

        send_data csv, type: 'text/csv; charset=utf-8', disposition: "filename=#{filename}.csv"
      end
    end
  end

  def import_antennes
    @result = CsvImport::AntenneImporter.import(params.require(:file), @institution)
    if @result.success?
      flash[:table_highlighted_ids] = @result.objects.map(&:id)
      redirect_to action: :antennes
    end
  end

  def import_advisors
    @result = CsvImport::UserImporter.import(params.require(:file), @institution)
    if @result.success?
      flash[:table_highlighted_ids] = @result.objects.map(&:id)
      redirect_to action: :advisors
    end
  end

  private

  def retrieve_institution
    @institution = Institution.find_by(slug: params[:slug])
    authorize @institution

    @institutions_subjects = @institution.institutions_subjects
      .ordered_for_interview
      .preload(:subject, :theme, :experts_subjects)

    @antennes = @institution.antennes
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
