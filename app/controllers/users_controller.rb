# frozen_string_literal: true

class UsersController < ApplicationController
  include FlashToReviewSubjects

  def show
    @user = current_user
  end
end
