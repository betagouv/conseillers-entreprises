module Annuaire
  class FileImportsController < BaseController
    before_action :retrieve_institution, only: [:form, :create]

    def form

    end

    def create
      entity = params[:entity]
      @import = FileImport.create(entity: entity, institution: @institution, user: current_user)
      @import.file.attach(params[:file])

      redirect_to analysis_institution_file_import_path(id: @import)
    end

    def update
      @import = FileImport.find(params[:id])
      @import.update(params)
      redirect_to action: :analysis
    end

    def analysis
      @import = FileImport.find(params[:id])
      @institution = @import.institution
      @result = @import.import(true)
    end

    def preview
      @import = FileImport.find(params[:id])
      @institution = @import.institution
      @import.import(true) do
        @users_data = UsersData.new(@institution, nil, {}, {}, flash, session).preload
      end
    end

    def commit
      @import = FileImport.find(params[:id])
      @import.import(false)

      redirect_to institution_users_path(@import.institution)
    end
  end
end
