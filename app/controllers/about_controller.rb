class AboutController < ApplicationController
  skip_before_action :authenticate_user!
  layout 'solicitations'

  def show; end

  def cgu; end
end
