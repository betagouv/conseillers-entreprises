module PersistedSearch
  extend ActiveSupport::Concern

  included do
    before_action :persist_index_search_params
    helper_method :index_search_params
    helper_method :possible_territories_options
  end

  private

  def index_search_params
    session[search_params_label]&.with_indifferent_access || {}
  end

  def persist_index_search_params
    session[search_params_label] ||= {}

    if params[:reset_query].present?
      session.delete(search_params_label)
    else
      search_params = params.slice(*search_fields).permit!
      session[search_params_label] = session[search_params_label].merge(search_params)
    end
  end

  def possible_territories_options
    @options ||= Territory.regions
      .pluck(:name, :id)
      .push(
        [ t('helpers.solicitation.uncategorisable_label'), t('helpers.solicitation.uncategorisable_value') ]
      )
  end
end
