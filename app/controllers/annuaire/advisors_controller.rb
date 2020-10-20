module  Annuaire
  class AdvisorsController < BaseController
    def index
      respond_to do |format|
        format.html
        format.csv do
          result = @advisors.export_csv(include_expert_team: true, institutions_subjects: @institutions_subjects)
          send_data result.csv, type: 'text/csv; charset=utf-8', disposition: "attachment; filename=#{result.filename}.csv"
        end
      end
    end

    def import; end

    def import_create
      @result = User.import_csv(params.require(:file), institution: @institution)
      if @result.success?
        flash[:table_highlighted_ids] = @result.objects.map(&:id)
        redirect_to action: :index
      else
        render :import
      end
    end
  end
end
