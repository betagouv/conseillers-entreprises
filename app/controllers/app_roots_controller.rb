class AppRootsController < ApplicationController # I’d rather call it AppRootController
  def show
    redirect_to app_root_for_user
  end
end
