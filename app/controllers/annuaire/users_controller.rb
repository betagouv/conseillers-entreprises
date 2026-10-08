module Annuaire
  class UsersController < BaseController
    include InstitutionsSubjectsSorter

    before_action :retrieve_institution
    before_action :retrieve_antenne, only: [:index, :create_territorial_coverage]
    before_action :retrieve_users_data, only: [:index, :create_territorial_coverage]
    before_action :retrieve_subjects, only: :index

    def index
      respond_to do |format|
        format.html do
          flash[:table_highlighted_ids] = User.where(id: params.expect(:advisor)).ids if params[:advisor].present?

          @users_data.preload
        end
        format.csv do
          users = @users_data.users
          result = users.export_csv(include_expert: true, institutions_subjects: @users_data.institutions_subjects)
          send_data result.csv, type: 'text/csv; charset=utf-8', disposition: "attachment; filename=#{result.filename}.csv"
        end
        format.xlsx do
          xlsx_filename = "#{(@antenne || @institution).name.parameterize}-#{User.model_name.human.pluralize.parameterize}.xlsx"
          result = XlsxExport::AnnuaireUserExporter.new(@users_data.grouped_experts, { relation_name: 'User', institutions_subjects: @users_data.institutions_subjects }).export
          send_data result.xlsx.to_stream.read, type: "application/xlsx", filename: xlsx_filename
        end
      end
    end

    def send_invitations
      invite_count = 0
      params.expect(:users_ids).split.each do |user_id|
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
        render :import, status: :unprocessable_content
      end
    end

    def create_territorial_coverage
      institution_subject = InstitutionSubject.find_by(id: params[:institution_subject_id])
      coverage = Rails.cache.fetch(["coverage-service", institution_subject, @users_data.antennes], expires_in: 2.minutes) do
        CreateTerritorialCoverage.new(institution_subject, @users_data.antennes).call
      end
      render partial: 'annuaire/users/coverage', locals: { institution_subject: institution_subject, coverage: coverage }
    end

    private

    def retrieve_antenne
      @antenne = @institution.antennes.find_by(id: params[:antenne_id]) # may be nil
    end

    def retrieve_users_data
      base_experts = Expert.by_region(index_search_params[:region_code])
        .by_theme(index_search_params[:theme_id])
        .by_subject(index_search_params[:subject_id])

      highlighted_antennes_ids = session.delete(:highlighted_antennes_ids)
      if highlighted_antennes_ids.present?
        base_experts = base_experts.joins(:antenne).where(antenne: { id: highlighted_antennes_ids })
      end

      # Si il y a des filtres de recherche par theme ou sujet, on ne prend pas les antennes sans experts pour ne pas polluer l'affichage
      base_antennes = if index_search_params[:theme_id].present? || index_search_params[:subject_id].present? || highlighted_antennes_ids.present?
        Antenne.none
      else
        Antenne.by_region(index_search_params[:region_code])
      end

      @users_data = UsersData.new(@institution, @antenne, base_experts: base_experts, base_antennes: base_antennes)
    end
  end
end
