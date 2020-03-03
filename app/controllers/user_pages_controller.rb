# frozen_string_literal: true

class UserPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:tutoriels]

  def tutoriels; end
end
