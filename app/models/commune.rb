class Commune < ApplicationRecord
  INSEE_CODE_FORMAT = /\A[0-9AB]{5}\z/

  validates :insee_code, presence: true, uniqueness: true, format: { with: INSEE_CODE_FORMAT }

  has_and_belongs_to_many :territories
  has_many :facilities
  has_and_belongs_to_many :antennes

  has_many :experts, through: :territories # this is the current state of data and will be `through: :antennes`
  has_many :relays, through: :territories

  def to_s
    insee_code
  end
end
