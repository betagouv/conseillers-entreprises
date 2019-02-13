class Solicitation < ApplicationRecord
  include ActiveModel::Model

  attr_accessor :description, :email, :phone_number, :besoins

  validates :phone_number, presence: true
  validates :email, format: { with: PersonConcern::EMAIL_REGEXP }, allow_blank: true
  validates :description, presence: true
end
