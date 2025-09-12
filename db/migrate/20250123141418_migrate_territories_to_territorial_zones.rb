class MigrateTerritoriesToTerritorialZones < ActiveRecord::Migration[7.2]
  def up
    models_with_territories = ["Antenne", "Expert"]

    # Cache les données DecoupageAdministratif pour éviter les parcours répétitifs
    cache_departements_regions

    create_regional_zones
    models_with_territories.each do |model|
      create_local_zones(model)
    end
  end

  private

  def cache_departements_regions
    puts "Mise en cache des données DecoupageAdministratif..."

    @departements_cache = {}
    @regions_cache = {}

    DecoupageAdministratif::Departement.all.each do |dept|
      region = dept.region
      @departements_cache[dept.code] = {
        region_code: region.code,
        communes_count: dept.communes.size,
        communes_codes: dept.communes.map(&:code)
      }
      @regions_cache[region.code] ||= region
    end

    @epcis_by_commune = {}
    DecoupageAdministratif::Epci.all.each do |epci|
      epci.membres.each do |membre|
        @epcis_by_commune[membre['code']] ||= []
        @epcis_by_commune[membre['code']] << epci
      end
    end

    puts "Cache terminé : #{@departements_cache.size} départements, #{@epcis_by_commune.keys.size} EPCI avec communes"
  end

  def create_regional_zones
    puts "Antennes régionales"

    regional_antennes = Antenne.not_deleted
      .territorial_level_regional
      .includes(:communes)

    regional_antennes_bar = ProgressBar.new(regional_antennes.count)

    regional_antennes.find_in_batches(batch_size: 100) do |batch|
      zones_to_insert = []

      batch.each do |antenne|
        departements_codes = antenne.communes.map do |commune|
          code = commune.insee_code
          code[0..1].to_i < 96 ? code[0..1] : code[0..2]
        end.uniq

        regions_codes = departements_codes.filter_map { |code| @departements_cache[code]&.dig(:region_code) }.uniq

        regions_codes.each do |region_code|
          zones_to_insert << {
            zone_type: 'region',
            code: region_code,
            regions_codes: [region_code],
            zoneable_type: 'Antenne',
            zoneable_id: antenne.id,
            created_at: Time.current,
            updated_at: Time.current
          }
        end

        regional_antennes_bar.increment!
      end

      TerritorialZone.insert_all(zones_to_insert) if zones_to_insert.any?
    end
  end

  def create_local_zones(model)
    puts "#{model} locales"
    model_collection = local_model_collection(model).includes(:communes)
    puts "Nombre de #{model} : #{model_collection.count}"
    local_bar = ProgressBar.new(model_collection.count)

    items_sans_zones = []

    model_collection.find_in_batches(batch_size: 100) do |batch|
      zones_to_insert = []

      batch.each do |item|
        communes_codes = item.communes.map(&:insee_code).uniq

        # Process départements
        communes_codes_remaining = process_departements_batch(item, communes_codes, zones_to_insert)

        # Process EPCIs
        if communes_codes_remaining.any?
          communes_codes_remaining = process_epcis_batch(item, communes_codes_remaining, zones_to_insert)
        end

        # Process remaining communes
        if communes_codes_remaining.any?
          communes_codes_remaining = process_communes_batch(item, communes_codes_remaining, zones_to_insert)
        end

        items_sans_zones << "#{item} (#{item.id}) sans zone : #{communes_codes_remaining.join(', ')}" if communes_codes_remaining.size >= 1
        local_bar.increment!
      end
      # Batch insert
      TerritorialZone.insert_all(zones_to_insert) if zones_to_insert.any?
    end

    items_sans_zones.each { |a| puts a }
  end

  def process_departements_batch(item, communes_codes, zones_to_insert)
    remaining_codes = Set.new(communes_codes)

    # Groupe par département
    codes_by_dept = communes_codes.group_by do |code|
      code[0..1].to_i < 96 ? code[0..1] : code[0..2]
    end

    codes_by_dept.each do |dept_code, dept_commune_codes|
      dept_info = @departements_cache[dept_code]
      next unless dept_info

      # Check si couvre 100% ou au moins 95% du département
      if dept_commune_codes.size >= dept_info[:communes_count] || dept_commune_codes.size >= (dept_info[:communes_count] * 0.95)
        zones_to_insert << {
          zone_type: 'departement',
          code: dept_code,
          regions_codes: [dept_info[:region_code]],
          zoneable_type: item.class.name,
          zoneable_id: item.id,
          created_at: Time.current,
          updated_at: Time.current
        }

        # Enlève ces codes de la liste restante
        dept_commune_codes.each { |code| remaining_codes.delete(code) }
      end
    end

    remaining_codes.to_a
  end

  def process_epcis_batch(item, communes_codes, zones_to_insert)
    remaining_codes = Set.new(communes_codes)
    processed_epcis = Set.new

    epcis = DecoupageAdministratif::Epci.search_by_communes_codes(communes_codes)

    epcis.each do |epci|
      next if processed_epcis.include?(epci.code)

      epci_regions_codes = epci.regions.map(&:code).uniq

      zones_to_insert << {
        zone_type: 'epci',
        code: epci.code,
        regions_codes: epci_regions_codes,
        zoneable_type: item.class.name,
        zoneable_id: item.id,
        created_at: Time.current,
        updated_at: Time.current
      }

      processed_epcis.add(epci.code)
      # Supprime les communes de l'EPCI de la liste restante
      epci.membres.each { |membre| remaining_codes.delete(membre['code']) }
    end

    remaining_codes.to_a
  end

  def process_communes_batch(item, communes_codes, zones_to_insert)
    invalid_codes = []

    communes_codes.each do |code|
      # Vérifie la validité du code commune
      if valid_commune_code?(code)
        dept_code = code[0..1].to_i < 96 ? code[0..1] : code[0..2]
        region_code = @departements_cache[dept_code]&.dig(:region_code)
        
        zones_to_insert << {
          zone_type: 'commune',
          code: code,
          regions_codes: [region_code],
          zoneable_type: item.class.name,
          zoneable_id: item.id,
          created_at: Time.current,
          updated_at: Time.current
        }
      else
        invalid_codes << code
      end
    end

    # Retourne les codes invalides non traités
    invalid_codes
  end

  def valid_commune_code?(code)
    return false if code.blank?

    begin
      DecoupageAdministratif::Commune.find(code).present?
    rescue
      false
    end
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
