# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  layout 'home'

  def index; end

  def about; end

  def cgu; end

  def team
    @relays = User.relays.ordered_for_contact
    @product_team = User.project_team.ordered_for_contact.uniq
  end
end
