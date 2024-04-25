# frozen_string_literal: true

class UserPagesController < ApplicationController
  before_action :fetch_themes

  def tutoriels; end

  def bascule_seen
    return unless current_user
    current_user.update(bascule_seen: true)
    head :ok
  end
end
