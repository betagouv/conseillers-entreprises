module Annuaire
  class FileImportsController < BaseController
    before_action -> { authorize [:annuaire, FileImport] }
    before_action :retrieve_institution, only: [:create]
    before_action :retrieve_import, only: [:analysis, :preview, :commit]

    def create
      entity = params[:entity]
      @import = FileImport.create(entity: entity, institution: @institution, author: current_user)
      @import.file.attach(params[:file])

      redirect_to analysis_institution_file_import_path(id: @import)
    end

    def analysis
      @result = @import.import(commit: false)
    end

    def preview
      case @import.entity.to_s
      when "User"
        old_data = UsersData.new(@institution, nil).preload
        @import.import(commit: false) do |result|
          new_data = UsersData.new(@institution, nil).preload
          @users_data = Annuaire::ImportedUsersData.new(new_data, result.objects, old_data, filter: params[:display_filter]&.to_sym)
        end
      when "Antenne"
        @result = @import.import(commit: false) do |result|
          @antennes = @institution.antennes.not_deleted.apply_filters(index_search_params)
            .with_count(:experts, :advisors)
            .order(:name)
            .preload(:managers, :territorial_zones)
        end
      end
    end

    def commit
      @import.import(commit: true)

      case @import.entity.to_s
      when "User"
        redirect_to institution_users_path(@import.institution, highlight_last_import: true)
      when "Antenne"
        redirect_to institution_antennes_path(@import.institution, highlight_last_import: true)
      end
    end

    private

    def retrieve_import
      @import = FileImport.find(params.expect(:id))
      @institution = @import.institution
    end
  end
end
