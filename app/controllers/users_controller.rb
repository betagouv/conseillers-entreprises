# frozen_string_literal: true

class UsersController < ApplicationController
  def show
    @user = current_user
  end

  def update
    if current_user.update_without_password(user_params)
      @user = current_user
    else
      data = {
        status: 'could not save data',
        errors: 422
      }
      render json: data, status: 422
    end
  end

  protected

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :institution, :role, :phone_number)
  end
end
