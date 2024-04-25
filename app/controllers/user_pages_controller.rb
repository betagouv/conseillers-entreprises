# frozen_string_literal: true

class UserPagesController < ApplicationController
  before_action :fetch_themes

  def tutoriels; end

  def session_param
    return unless current_user
    session[:modal_seen] = true
    head :ok
  end
end
