class AboutController < ApplicationController
  skip_before_action :authenticate_user!
  layout 'solicitations'

  def qui_sommes_nous; end

  def cgu; end
end
