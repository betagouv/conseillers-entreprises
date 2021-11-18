module ManyCommunes
  extend ActiveSupport::Concern

  ## Insee Codes acccessors
  #
  def insee_codes
    communes.pluck(:insee_code).join(' ')
  end

  def insee_codes=(codes_raw)
    wanted_codes = codes_raw.split(/[,\s]/).delete_if(&:empty?)
    if wanted_codes.any? { |code| code !~ Commune::INSEE_CODE_FORMAT }
      self.insee_codes_error = :invalid_insee_codes
      return
    else
      self.insee_codes_error = nil
    end

    if wanted_codes.present?
      # Make a single query to insert missing communes.
      # insert_all skips duplicates, so maybe we're not doing anything but we don't care.
      Commune.insert_all wanted_codes.map{ |code| { insee_code: code } }
    end

    self.communes = Commune.where(insee_code: wanted_codes)
  end

  ## Validation Support
  # The error is set in the insee_codes= setter, and checked in the validation method
  included do
    attr_accessor :insee_codes_error

    validate do
      if insee_codes_error.present?
        errors.add(:insee_codes, insee_codes_error)
      end
    end
  end

  ## Territories description
  #
  def intervention_zone_summary
    self_communes = communes.ids
    territories_covered = []
    remaining_communes = self_communes.clone
    self.territories.or(self.regions).includes(:communes).order(:name).each do |territory|
      territory_communes = territory.communes.ids
      territory_communes_in_self = territory_communes & self_communes
      if territory_communes_in_self.size > 0
        territories_covered << {
          territory: territory,
          included: territory_communes_in_self.count,
        }
        remaining_communes -= territory_communes
      end
    end

    {
      territories: territories_covered,
      other: remaining_communes.count
    }
  end
end
