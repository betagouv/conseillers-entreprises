module  Annuaire
  class AntennesController < BaseController
    before_action :retrieve_antennes, only: %i[index search]
    before_action :retrieve_region_id, only: :search

    def index
      redirect_to search_institution_antennes_path(@institution) if session[:annuaire_region_id].present?

      respond_to do |format|
        format.html
        format.csv do
          result = @antennes.export_csv
          send_data result.csv, type: 'text/csv; charset=utf-8', disposition: "attachment; filename=#{result.filename}.csv"
        end
      end
    end

    def search
      @antennes = @institution.antennes_in_region(@region_id)
      render :index
    end

    def clear_search
      clear_annuaire_session
      redirect_to institution_antennes_path(@institution)
    end

    def import; end

    def import_create
      @result = Antenne.import_csv(params.require(:file), institution: @institution)
      if @result.success?
        flash[:table_highlighted_ids] = @result.objects.map(&:id)
        redirect_to action: :index
      else
        render :import
      end
    end

    private

    def retrieve_antennes
      @antennes = @institution.antennes
        .not_deleted
        .order(:name)
        .preload(:communes)
    end
  end
end
