module Reminders
  class BaseController < ApplicationController
    include PersistedSearch

    before_action :authenticate_admin!

    layout 'side_menu'

    private

    # Filtering
    #
    def search_session_key
      :reminders_filter_params
    end

    def search_fields
      [:by_region, :institution_id, :by_full_name]
    end
  end
end
