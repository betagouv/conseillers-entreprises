module Annuaire
  class FileImportsController < BaseController
    before_action :retrieve_institution, only: :create

    def create
      entity = params[:entity]
      @import = FileImport.create(entity: entity, institution: @institution, user: current_user)
      @import.file.attach(params[:file])

      redirect_to action: :analysis
    end

    def update
      @import = FileImport.find(params[:id])
      @import.update(params)
      redirect_to action: :analysis
    end

    def analysis
      @import = FileImport.find(params[:id])
      @import.import(false)
    end

    def preview
      @import = FileImport.find(params[:id])
      @import.import(false)
    end

    def commit
      @import = FileImport.find(params[:id])
      @import.import(false)
    end
  end
end
