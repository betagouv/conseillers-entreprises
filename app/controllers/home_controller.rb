# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  layout 'home'

  def index; end

  def about; end

  def cgu; end

  def team
    @relays = User.approved.relays.ordered_for_contact
    @product_team = User.approved.project_team.ordered_for_contact.uniq
  end
end
