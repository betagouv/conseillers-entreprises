class AppRootsController < ApplicationController
  # Redirect /app to the user-dependent root of the app
  def show = redirect_to app_root_for_user
end
