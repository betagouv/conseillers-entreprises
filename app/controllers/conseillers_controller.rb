class ConseillersController < ApplicationController
  skip_before_action :authenticate_user!
  layout 'home'

  def show; end
end
