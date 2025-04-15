class MigrateTerritoriesToTerritorialZones < ActiveRecord::Migration[7.2]
  def up
    models_with_territories = ["Antenne", "Expert"]
    create_regional_zones
    models_with_territories.each do |model|
      create_local_zones(model)
    end
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

  def create_local_zones(model)
    puts "#{model} locales"
    model_collection = local_model_collection(model)
    puts "Nombre de #{model} : #{model_collection.count}"
    local_bar = ProgressBar.new(model_collection.count)
    avec_code = []
    transaction do
      model_collection.each do |item|
        communes_codes = item.communes.pluck(:insee_code).uniq.flatten
        communes_codes = check_and_create_if_departement(communes_codes, item)

        if communes_codes.size > 0
          communes_codes = check_and_create_if_epci(communes_codes, item)
        end
        if communes_codes.size > 0
          communes_codes = create_communes(communes_codes, item)
        end
        avec_code << "#{item} (#{item.id}) sans zone : #{communes_codes.join(', ')}" if communes_codes.size >= 1
        local_bar.increment!
      end
      puts "---"
      puts "#{model} restants avec codes non créés"
      avec_code.each { |a| puts a }
      puts "---"
    end
  end

  def check_and_create_if_departement(communes_codes, item)
    code_departements = communes_codes.map do |code|
      code[0..1].to_i < 96 ? code[0..1] : code[0..2]
    end.uniq
    # Passe les antennes qui on beaucoup de codes communes d'un département mais qui ne sont pas départementales
    return communes_codes if item.is_a?(Antenne) && [303, 2621, 2630, 2631, 2823, 1012, 305, 2616, 159, 848, 152, 768, 2272, 1529, 764, 1747].include?(item.id)
    code_departements.each do |code_departement|
      communes_departement_size = communes_codes.count { |code| code.start_with?(code_departement) }
      reel_departement_size = DecoupageAdministratif::Departement.find_by_code(code_departement).communes.size
      if communes_departement_size >= reel_departement_size || communes_departement_size >= (reel_departement_size * 0.95)
        item.territorial_zones.create!(zone_type: :departement, code: code_departement)
        communes_codes.reject! { |code| code.start_with?(code_departement) }
      end
    end
    communes_codes
  end

  def check_and_create_if_epci(communes_codes, item)
    epcis = DecoupageAdministratif::Epci.find_by_communes_codes(communes_codes)
    epcis.each do |epci|
      item.territorial_zones.create!(zone_type: :epci, code: epci.code)
      communes_codes.reject! { |code| epci.communes.map(&:code) }
    end
    communes_codes
  end

  def create_communes(communes_codes, item)
    communes_codes.flatten.each do |code|
       tz = TerritorialZone.new(code: code, zone_type: :commune, zoneable: item)
       if tz.save
         communes_codes.reject! { |c| c == code }
       end
     end
    communes_codes
  end

  def local_model_collection(model)
    case model
    when "Antenne"
      Antenne.not_deleted.territorial_level_local
    when "Expert"
      Expert.not_deleted
    end
  end
end
