# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  layout 'home'

  def index; end

  def about; end

  def cgu; end

  def contact
    @territory_administrators = User.administrators_of_territory.includes(territory_users: :territory)
    @product_team = User.with_contact_page_order
  end

  def tutorial_video
    redirect_to ENV['TUTORIAL_VIDEO_URL'] || root_path
  end
end
