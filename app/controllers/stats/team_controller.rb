module Stats
  class TeamController < BaseController
    include LoadFilterOptions

    before_action :authorize_team
    before_action :init_filters, except: %i[search_antennes]
    before_action :clean_public_filters, only: :public
    before_action :set_stats_params, only: %i[public needs matches acquisition]

    def index
      redirect_to action: :public
    end

    def public
      @charts_names = %w[
        solicitations_completed solicitations_diagnoses needs_exchange_with_expert needs_done
        needs_taken_care_in_three_days needs_taken_care_in_five_days
        needs_themes_all needs_subjects_all companies_by_employees companies_by_naf_code
      ]
      render :index
    end

    def needs
      @charts_names = %w[
        solicitations_transmitted_less_than_72h needs_quo needs_taking_care needs_done needs_done_no_help
        needs_done_not_reachable needs_not_for_me needs_abandoned_total_count needs_abandoned
      ]
      render :index
    end

    def matches
      @charts_names = %w[
        needs_transmitted matches_positioning matches_taking_care matches_done
        matches_done_no_help matches_done_not_reachable matches_not_for_me matches_not_positioning
        matches_taken_care_in_three_days matches_taken_care_in_five_days
      ] + themes_subjects_charts +
      %w[
        companies_by_employees companies_by_naf_code
      ]
      render :index
    end

    def acquisition
      @charts_names = %w[
        acquisitions_overall_distribution_solicitations acquisitions_overall_distribution_solicitations_column
        acquisitions_overall_distribution_needs_transmitted acquisitions_overall_distribution_needs_transmitted_column
        acquisitions_overall_distribution_needs_done_with_help acquisitions_overall_distribution_needs_done_with_help_column
      ]
      render :index
    end

    def load_data
      name = params.permit(:chart_name)[:chart_name]
      data = Rails.cache.fetch(['team-public-stats', name, session[:team_stats_params]], expires_in: 6.hours) do
        invoke_stats(name, session[:team_stats_params])
      end
      render_partial(data, name)
    end

    private

    def authorize_team
      authorize Stats::All, :team?
    end

    def render_partial(data, name)
      render partial: 'stats/load_stats', locals: { data: data, name: name }
    end

    def clean_public_filters
      # Remove institution and antenne filters for public stats
      params.delete(:institution_id)
      params.delete(:antenne_id)
    end

    def set_stats_params
      @stats_params = stats_params
      @stats_params[:has_external_cooperation] = base_needs_for_filters.from_external_cooperation.limit(1).any?
      session[:team_stats_params] = @stats_params
    end

    def themes_subjects_charts
      if @stats_params[:has_external_cooperation]
        %w[needs_themes_not_from_external_cooperation needs_themes_from_external_cooperation needs_subjects_not_from_external_cooperation needs_subjects_from_external_cooperation]
      else
        %w[needs_themes_all needs_subjects_all]
      end
    end

    def base_needs_for_filters
      @base_needs_for_filters ||= begin
        # Build base scope similar to Stats::Needs::Base
        base_scope = Need.diagnosis_completed
          .joins(:diagnosis).merge(Diagnosis.from_solicitation)
          .where(created_at: @stats_params[:start_date]..@stats_params[:end_date])

        # Apply filters using Stats::Filters::Needs
        graph_struct = OpenStruct.new(@stats_params)
        graph_struct.antenne_or_institution = Antenne.find_by(id: @stats_params[:antenne_id]).presence ||
                                               Institution.find_by(id: @stats_params[:institution_id]).presence
        # Calculate with_agglomerate_data similar to Stats::BaseStats
        graph_struct.with_agglomerate_data = @stats_params[:antenne_id].to_s.include?('locales') if @stats_params[:antenne_id].present?
        Stats::Filters::Needs.new(base_scope, graph_struct).call.distinct
      end
    end
  end
end
