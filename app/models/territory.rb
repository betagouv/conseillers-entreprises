# frozen_string_literal: true

class Territory < ApplicationRecord
  ## Relations and Validations
  #
  include ManyCommunes
  has_many :relays
  has_many :users, through: :relays

  has_many :antennes, -> { distinct }, through: :communes
  has_many :advisors, -> { distinct }, through: :antennes, source: :users
  has_many :experts, -> { distinct }, through: :antennes

  ## Scopes
  #
  scope :ordered_by_name, -> { order(:name) }
  scope :bassins_emploi, -> { where(bassin_emploi: true) }

  ##
  #
  def to_s
    name
  end
end
