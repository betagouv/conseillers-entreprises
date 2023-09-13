# frozen_string_literal: true

class UserPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:tutoriels]
  before_action :fetch_themes

  def tutoriels; end
end
