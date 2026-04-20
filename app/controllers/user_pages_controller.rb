class UserPagesController < ApplicationController
  before_action :fetch_themes

  def tutoriels; end

  # User-info flags, such as “notifications read” markers.
  # See also user_app_info_controller.js
  def app_info
    return unless current_user
    return unless params[:key].in? User::APP_INFO_KEYS

    current_user.update(params[:key] => DateTime.now)

    head :no_content
  end
end
