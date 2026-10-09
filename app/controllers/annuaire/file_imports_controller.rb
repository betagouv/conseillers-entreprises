module Annuaire
  class FileImportsController < BaseController
    before_action :retrieve_institution, only: [:new, :create]
    before_action :retrieve_import, only: [:update, :analysis, :preview, :commit]

    def new
      @entity = params[:entity]
    end

    def create
      entity = params[:entity]
      @import = FileImport.create(entity: entity, institution: @institution, user: current_user)
      @import.file.attach(params[:file])

      redirect_to analysis_institution_file_import_path(id: @import)
    end

    def update # not used yet.
      @import.update(params)
      redirect_to action: :analysis
    end

    def analysis
      @result = @import.import(commit: false)
    end

    def preview
      @result = @import.import(commit: false) do
        @users_data = UsersData.new(@institution, nil).preload
      end
    end

    def commit
      @import.import(commit: true)

      redirect_to institution_users_path(@import.institution)
    end

    private

    def retrieve_import
      @import = FileImport.find(params.expect(:id))
      @institution = @import.institution
    end

  end
end
