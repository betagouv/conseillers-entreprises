class AboutController < ApplicationController
  skip_before_action :authenticate_user!
  layout 'solicitations'

  def cgu; end

  def qui_sommes_nous; end

  def top_5; end
end
