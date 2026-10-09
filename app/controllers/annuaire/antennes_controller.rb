module Annuaire
  class AntennesController < BaseController
    before_action :retrieve_institution
    before_action :retrieve_antennes, only: :index

    def index
      respond_to do |format|
        format.html
        format.csv do
          result = @antennes.export_csv
          send_data result.csv, type: 'text/csv; charset=utf-8', disposition: "attachment; filename=#{result.filename}.csv"
        end
      end
    end

    private

    def retrieve_antennes
      @antennes = @institution.antennes.not_deleted.apply_filters(index_search_params)
        .with_count(:experts, :advisors)
        .order(:name)
        .preload(:managers, :territorial_zones)
    end
  end
end
