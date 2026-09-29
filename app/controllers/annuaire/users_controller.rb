module Annuaire
  class UsersController < BaseController
    include InstitutionsSubjectsSorter

    before_action :retrieve_institution
    before_action :retrieve_antenne, only: [:index, :create_territorial_coverage]
    before_action :retrieve_grouped_experts, only: [:index, :create_territorial_coverage]

    before_action :retrieve_subjects, only: :index

    def index
      institutions_subjects_by_theme = @institution.institutions_subjects
        .includes(:subject, :experts_subjects, :not_deleted_experts, theme: [:territorial_zones, :cooperations])
        .sort { |a, b| compare_institution_subjects(a, b) }
        .group_by(&:theme)
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
      coverage = Rails.cache.fetch(["coverage-service", institution_subject, @grouped_experts], expires_in: 2.minutes) do
        CreateTerritorialCoverage.new(institution_subject, @grouped_experts).call
      end
      render partial: 'annuaire/users/coverage', locals: { institution_subject: institution_subject, coverage: coverage }
    end

    private

    def retrieve_antenne
      @antenne = @institution.antennes.find_by(id: params[:antenne_id]) # may be nil
    end

    def retrieve_grouped_experts
      @grouped_experts = UsersData.new(@institution, @antenne, params, index_search_params, flash, session).grouped_experts
    end

    def retrieve_users
      user_ids = @grouped_experts.values.flat_map(&:values).flatten.map(&:id).uniq
      User.where(id: user_ids)
    end

    def not_invited_users
      if flash[:table_highlighted_ids].present?
        User.not_deleted.where(id: flash[:table_highlighted_ids]).where(invitation_sent_at: nil)
      else
        # Ne prend pas @experts directement pour avoir les responsables sans experts
        User.not_deleted.joins(:antenne).where(antenne: @grouped_experts.keys, invitation_sent_at: nil)
      end
    end
  end
end
