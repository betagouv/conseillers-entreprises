# frozen_string_literal: true

class Territory < ApplicationRecord
  has_and_belongs_to_many :communes
  has_many :relays
  has_many :users, through: :relays

  accepts_nested_attributes_for :communes

  scope :ordered_by_name, (-> { order(:name) })

  def to_s
    "#{id} : #{name}"
  end

  def insee_codes
    communes.pluck(:insee_code)
  end

  def insee_codes=(codes_raw)
    wanted_codes = codes_raw.split(/[,\s]/).delete_if(&:empty?)
    if wanted_codes.any? { |code| code !~ Commune::INSEE_CODE_FORMAT }
      raise 'Invalid city codes'
    end

    wanted_codes.each do |code|
      Commune.find_or_create_by(insee_code: code)
    end

    self.communes = Commune.where(insee_code: wanted_codes)
  end
end
