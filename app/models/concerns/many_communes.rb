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
      raise 'Invalid city codes'
    end

    wanted_codes.each do |code|
      Commune.find_or_create_by(insee_code: code)
    end

    self.communes = Commune.where(insee_code: wanted_codes)
  end

  ## Territories description
  #
  def intervention_zone_summary
    self_communes = communes.ids
    territories_covered = []
    remaining_communes = self_communes.clone
    self.territories.bassins_emploi.distinct.includes(:communes).order(:name).each do |territory|
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
