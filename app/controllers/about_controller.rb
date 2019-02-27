class AboutController < ApplicationController
  skip_before_action :authenticate_user!
  layout 'home'

  def show; end

  def cgu; end

  def qui_sommes_nous
    @relays = User.approved.relays.ordered_for_contact
    @product_team = User.approved.project_team.ordered_for_contact.uniq
  end
end
