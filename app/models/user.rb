# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :confirmable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  def active_for_authentication?
    super && is_approved?
  end

  def inactive_message
    if !is_approved?
      :not_approved
    else
      super
    end
  end
end
