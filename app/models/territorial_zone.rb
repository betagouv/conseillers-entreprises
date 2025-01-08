# == Schema Information
#
# Table name: territorial_zones
#
#  id            :bigint(8)        not null, primary key
#  code          :string           not null
#  zone_type     :string           not null
#  zoneable_type :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  zoneable_id   :bigint(8)        not null
#
# Indexes
#
#  index_territorial_zones_on_code_and_zone_type_and_zoneable_id  (code,zone_type,zoneable_id) UNIQUE
#  index_territorial_zones_on_zoneable                            (zoneable_type,zoneable_id)
#
class TerritorialZone < ApplicationRecord
  enum zone_type: { commune: 0, epci: 1, departement: 2, region: 3 }

  belongs_to :zoneable, polymorphic: true

  validates :code, :zone_type, presence: true
  validate :validate_code_format

  private

  def validate_code_format
    error_message = I18n.t('activerecord.errors.models.territorial_zones.code.format_invalid', zone_type: zone_type)
    case zone_type
    when 'commune'
      errors.add(:code, error_message) unless code.match?(/^\d{5}$/)
    when 'departement'
      errors.add(:code, error_message) unless code.match?(/^\d{2,3}$/)
    when 'region'
      errors.add(:code, error_message) unless code.match?(/^\d{2}$/)
    when 'epci'
      errors.add(:code, error_message) unless code.match?(/^\d{9}$/)
    end
  end
end
