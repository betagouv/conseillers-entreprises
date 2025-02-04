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
#  idx_on_code_zone_type_zoneable_type_zoneable_id_0c5f85b4e4  (code,zone_type,zoneable_type,zoneable_id) UNIQUE
#  index_territorial_zones_on_zoneable                         (zoneable_type,zoneable_id)
#
class TerritorialZone < ApplicationRecord
  enum zone_type: { commune: 'commune', epci: 'epci', departement: 'departement', region: 'region' }

  belongs_to :zoneable, polymorphic: true

  validates :code, :zone_type, presence: true
  validate :validate_code_format
  validate :validate_existence

  def antenne
    zoneable.instance_of?(Antenne) ? zoneable : nil
  end

  private

  def validate_code_format
    error_message = I18n.t('activerecord.errors.models.territorial_zones.code.invalid_format', zone_type: zone_type)
    case zone_type
    when 'commune'
      errors.add(:code, error_message) unless code.match?(/^(?:[0-9]{2}[0-9]{3}|2[AB][0-9]{3})$/)
    when 'departement'
      errors.add(:code, error_message) unless code.match?(/^(?:[0-9]{2}|2[AB]|[0-9]{3})$/)
    when 'region'
      errors.add(:code, error_message) unless code.match?(/^\d{2}$/)
    when 'epci'
      errors.add(:code, error_message) unless code.match?(/^\d{9}$/)
    end
  end

  def validate_existence
    zone = I18n.t(zone_type, scope: 'activerecord.attributes.territorial_zone')
    error_message = I18n.t('activerecord.errors.models.territorial_zones.code.not_found', zone_type: zone.capitalize)
    model = "DecoupageAdministratif::#{self.zone_type.classify}".constantize.send(:find_by_code, code)
    return errors.add(:code, error_message) if model.nil?
  end
end
