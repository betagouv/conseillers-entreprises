# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  layout 'home'

  def index; end

  def about; end

  def cgu; end

  def contact
    @relays = User.contact_relays.includes(relays: :territory)
    @product_team = User.with_contact_page_order
  end

  def tutorial_video
    redirect_to ENV['TUTORIAL_VIDEO_URL'] || root_path
  end
end
