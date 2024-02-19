module Stats
  class BaseController < PagesController
    include StatsHelper

    def set_filter_options
      antennes = Antenne.all
      themes = Theme.all
      subjects = Subject.not_archived.all
      
      if params[:institution_id].present?
        institution = Institution.find(params.permit(:institution_id)[:institution_id])
        antennes = build_institution_antennes_collection(institution)
        themes = themes.merge(institution.themes.order(:label))
        subjects = subjects.merge(institution.subjects.not_archived.order(:label))
      end
      if params[:theme_id].present? && themes.pluck(:id).include?(params[:theme_id].to_i)
        subjects = subjects.merge(Subject.where(theme_id: params[:theme_id]))
      end

      response = {
        antennes: antennes,
        themes: themes.distinct.select(:id, :label),
        subjects: subjects.select(:id, :label)
      }

      render json: response.as_json
    end

    private

    def stats_params
      stats_params = stats_filter_params
      stats_params[:start_date] ||= 6.months.ago.beginning_of_month.to_date
      stats_params[:end_date] ||= Date.today
      stats_params
    end

  end
end
