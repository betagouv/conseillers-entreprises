class MigrateTerritoriesToTerritorialZones < ActiveRecord::Migration[7.2]
  def up
    create_regional_zones
    create_local_zones
  end

  def down
    # TODO pas sure de garder ce bout de code
    TerritorialZone.delete_all
  end

  def create_regional_zones
    regional_antennes = Antenne.not_deleted.territorial_level_regional
    puts "Antennes régionales"
    regional_antennes_bar = ProgressBar.new(regional_antennes.count)
    transaction do
      regional_antennes.each do |antenne|
        antenne.regions.each do |region|
          code_region = if region.code_region < 10
            "0#{region.code_region}"
          else
            region.code_region
          end

          antenne.territorial_zones.create!(zone_type: :region, code: code_region)
          regional_antennes_bar.increment!
        end
      end
    end
  end

  def create_local_zones
    puts "Antennes locales"
    local_antennes = Antenne.not_deleted.territorial_level_local
    local_antennes_bar = ProgressBar.new(local_antennes.count)
    avec_code = []
    transaction do
      local_antennes.each do |antenne|
        communes_codes = antenne.communes.pluck(:insee_code)
        communes_codes = check_and_create_if_departement(communes_codes, antenne)
        if communes_codes.size > 1
          communes_codes = check_and_create_if_epci(communes_codes, antenne)
        end
        if communes_codes.size > 1
          communes_codes = create_communes(communes_codes, antenne)
        end
        avec_code << "antenne #{antenne.id} sans zone : #{communes_codes.join(', ')}" if communes_codes.size >= 1
        local_antennes_bar.increment!
      end
      puts "Antennes restantes avec codes non créés"
      avec_code.each { |a| puts a }
    end
  end

  def check_and_create_if_departement(communes_codes, antenne)
    code_departements = communes_codes.map do |code|
      code[0..1].to_i < 96 ? code[0..1] : code[0..2]
    end.uniq
    # TODO next si l'antenne a été annoncée pas dépaertemental par les bizdevs
    code_departements.each do |code_departement|
      communes_departement_size = communes_codes.count { |code| code.start_with?(code_departement) }
      reel_departement_size = DecoupageAdministratif::Departement.find_by_code(code_departement).communes.size
      if communes_departement_size >= reel_departement_size || communes_departement_size >= (reel_departement_size * 0.60)
        antenne.territorial_zones.create!(zone_type: :departement, code: code_departement)
        communes_codes.reject! { |code| code.start_with?(code_departement) }
      end
    end
    communes_codes
  end

  def check_and_create_if_epci(communes_codes, antenne)
    epcis = DecoupageAdministratif::Epci.find_by_communes_codes(communes_codes)
    epcis.each do |epci|
      antenne.territorial_zones.create!(zone_type: :epci, code: epci.code)
      communes_codes.reject! { |code| epci.membres.pluck("code") }
    end
    communes_codes
  end

  def create_communes(communes_codes, antenne)
    communes_codes.flatten.each do |code|
      tz = TerritorialZone.new(code: code, zone_type: :commune, zoneable: antenne)
      if tz.save
        communes_codes.reject! { |c| c == code }
      else
        puts "Erreur #{tz.errors.full_messages.join(', ')} : #{code}"
      end
    end
    communes_codes
  end
end
