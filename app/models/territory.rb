# frozen_string_literal: true

class Territory < ApplicationRecord
  ## Relations and Validations
  #
  include ManyCommunes
  has_many :relays
  has_many :users, through: :relays

  ## Scopes
  #
  scope :ordered_by_name, (-> { order(:name) })

  ##
  #
  def to_s
    "#{id} : #{name}"
  end
end
