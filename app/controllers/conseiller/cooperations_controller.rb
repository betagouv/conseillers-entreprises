class Conseiller::CooperationsController < ApplicationController
  include StatsUtilities
  # include LoadFilterOptions
  # include StatsHelper

  before_action :get_cooperation, only: %i[load_filter_options needs]
  before_action :init_filters, only: %i[load_filter_options needs]
  before_action :set_stats_params, only: %i[needs]

  def index
    authorize Cooperation, :index?
    cooperation = current_user.managed_cooperations.first
    redirect_to action: :needs, id: cooperation.id
  end

  def needs
    @charts_names = %w[
      solicitations_completed solicitations_diagnoses
      needs_positioning needs_done needs_done_no_help needs_done_not_reachable needs_not_for_me needs_taking_care
      needs_themes needs_subjects companies_by_employees companies_by_naf_code
    ]
  end

  def load_data
    name = params.permit(:chart_name)[:chart_name]
    data = Rails.cache.fetch(['cooperation-stats', name, session[:cooperation_stats_params]], expires_in: 6.hours) do
      invoke_stats(name, session[:cooperation_stats_params])
    end
    render partial: 'stats/load_stats', locals: { data: data, name: name }
  end

  def load_filter_options
    render json: @filters.as_json
  end

  private

  def get_cooperation
    @cooperation = Cooperation.find_by(id: params[:id])
    authorize @cooperation, :manage?
  end

  def init_filters
    themes = @cooperation.themes.select(:id, :label).order(:label).uniq
    subjects = @cooperation.subjects.not_archived.order(:label)

    # on verifie que le theme précédemment sélectionné fait bien partie des thèmes possibles
    if params[:theme].present? && themes.map(&:id).include?(params[:theme].to_i)
      subjects = subjects.where(theme_id: params[:theme])
    end
    @filters = {
      themes: themes,
      subjects: subjects,
      regions: Territory.regions
    }
  end

  def set_stats_params
    @stats_params = stats_params.merge(cooperation_id: @cooperation.id)
    session[:cooperation_stats_params] = @stats_params
  end
end