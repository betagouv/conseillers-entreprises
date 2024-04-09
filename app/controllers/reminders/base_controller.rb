module Reminders
  class BaseController < ApplicationController
    include PersistedSearch
    before_action :authenticate_admin!

    layout 'side_menu'

    private

    def collection_action_names
      %i[poke last_chance refused]
    end

    def experts_collection_names
      %i[inputs many_pending_needs medium_pending_needs one_pending_need expired_needs outputs]
    end

    # Filtering
    #
    def search_session_key
      :reminders_filter_params
    end

    def search_fields
      [:by_region, :by_full_name]
    end
  end
end
