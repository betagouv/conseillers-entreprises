module PersistedSearch
  extend ActiveSupport::Concern

  included do
    before_action :persist_index_search_params
    helper_method :index_search_params
    helper_method :possible_territories_options
  end

  private

  def index_search_params
    session[search_session_key]&.with_indifferent_access || {}
  end

  def persist_index_search_params
    session[search_session_key] ||= {}

    if params[:reset_query].present?
      session.delete(search_session_key)
    else
      search_params = params.slice(*search_fields).permit!
      session[search_session_key] = session[search_session_key].merge(search_params)
    end
  end

  def possible_territories_options
    @options ||= define_territory_options
  end

  def define_territory_options
    options = Territory.regions.pluck(:name, :id)
    options.push(territory_options_complement) if defined?(territory_options_complement)
    options
  end

  def reset_session
    session[search_session_key] = {}
  end
end
