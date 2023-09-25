module Stats
  class TeamController < BaseController
    before_action :authorize_team
    before_action :get_institution_antennes, except: %i[search_antennes]
    before_action :init_filters, except: %i[search_antennes]
    before_action :set_stats_params, only: %i[public needs matches]

    def index
      redirect_to action: :public
    end

    def public
      @stats_for = "Public"
      @charts_names = %w[
        solicitations solicitations_diagnoses exchange_with_expert taking_care themes
        companies_by_employees companies_by_naf_code
      ]
      render :index
    end

    def needs
      @stats_for = "Needs"
      @charts_names = %w[
        transmitted_less_than_72h_stats needs_done needs_done_no_help
        needs_done_not_reachable needs_not_for_me needs_abandoned
      ]
      render :index
    end

    def matches
      @stats_for = "Matches"
      @charts_names = %w[
        needs_transmitted, positioning_rate, taking_care_rate_stats, done_rate_stats,
        done_no_help_rate_stats, done_not_reachable_rate_stats, not_for_me_rate_stats, not_positioning_rate
      ]
      render :index
    end

    def load_data
      name = params.permit(:chart_name)[:chart_name]
      stats_for = params.permit(:stats_for)[:stats_for]
      data = Rails.cache.fetch(['team-public-stats', name, session[:team_stats_params]], expires_in: 6.hours) do
        "Stats::#{stats_for}::All".constantize.new(session[:team_stats_params]).send(name)
      end
      render_partial(data, name)
    end

    def institution_filters
      institution = Institution.find(params.permit(:institution_id)[:institution_id])
      response = {
        antennes: institution.antennes.not_deleted.order(:name),
        subjects: institution.subjects.not_archived.order(:label)
      }
      render json: response.as_json
    end

    private

    def authorize_team
      authorize Stats::All, :team?
    end

    def get_institution_antennes
      @institution_antennes = params[:institution].present? ?
                                Institution.find(params[:institution]).antennes.not_deleted.order(:name) : []
    end

    def init_filters
      @iframes = Landing.iframe.not_archived.order(:slug)
    end

    def render_partial(data, name)
      render partial: 'stats/load_stats', locals: { data: data, name: name }
    end

    def set_stats_params
      @stats_params = stats_params
      session[:team_stats_params] = @stats_params
    end
  end
end
