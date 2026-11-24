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
      send("preview_#{@import.entity.model_name.plural}")
    end

    def commit
      @import.import(commit: true)

      redirect_to polymorphic_path([:institution, @import.entity.model_name.plural.to_sym], institution_slug: @import.institution)
    end

    private

    def preview_antennes
      @import.import(commit: false) do |result|
        antennes = @institution.antennes.not_deleted.apply_filters(index_search_params)
          .with_count(:experts, :advisors)
          .order(:name)
          .preload(:managers, :territorial_zones)
        @data = { antennes: antennes, result: result }
      end
    end

    def preview_users
      @import.import(commit: false) do |result|
        @data = UsersData.new(@institution, nil).preload
      end
    end

    def retrieve_import
      @import = FileImport.find(params.expect(:id))
      @institution = @import.institution
    end
  end
end
