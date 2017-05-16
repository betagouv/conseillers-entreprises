# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable
end
