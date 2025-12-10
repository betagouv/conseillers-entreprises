task fix_arrondissement_territorial_zones: :environment do
  @parent_city_insee_codes = %w[75056 13055 69123].freeze # Paris, Marseille, Lyon
  @arrondissements_insee_codes = %w[
    75101 75102 75103 75104 75105 75106 75107 75108 75109 75110 75111 75112 75113 75114 75115 75116 75117 75118 75119
    75120 13201 13202 13203 13204 13205 13206 13207 13208 13209 13210 13211 13212 13213 13214 13215 13216 69381 69382
    69383 69384 69385 69386 69387 69388 69389
  ].freeze

  def process_record(record)
    arrondissement_communes = record.communes.select { |c| arrondissement?(c.insee_code) }
    return if arrondissement_communes.empty?

    department_codes = arrondissement_communes.map { |c| c.insee_code[0..1] }.uniq
    zones_to_remove = []
    record.territorial_zones.each do |tz|
      # Check if it's a parent city commune zone (ex: Paris 75056)
      if tz.zone_type == 'commune' && @parent_city_insee_codes.include?(tz.code)
        zones_to_remove << tz
      end

      # Check if it's a department zone (ex: Departement 75)
      if tz.zone_type == 'departement' && department_codes.include?(tz.code)
        zones_to_remove << tz
      end
    end

    return if zones_to_remove.empty?

    log_changes(record, arrondissement_communes, zones_to_remove)

    zones_to_remove.each(&:destroy)

    arrondissement_communes.each do |commune|
      # Create new TerritorialZone with correct zone_type and code
      record.territorial_zones.find_or_create_by!(zone_type: 'commune', code: commune.insee_code)
    end
  end

  def arrondissement?(insee_code)
    @arrondissements_insee_codes.include?(insee_code)
  end

  def log_changes(record, arrondissements, zones_to_remove)
    puts "Updating #{record.class.name} ##{record.id}:"
    puts "  - Found arrondissements (via old system): #{arrondissements.map(&:insee_code).join(', ')}"

    zones_to_remove.each do |zone|
      puts "  - Removing #{zone.zone_type} zone: #{zone.code}"
    end

    arrondissements.each do |commune|
      puts "  + Adding new zone for commune #{commune.insee_code}"
    end
  end

  # Find all commune IDs for Paris, Lyon, and Marseille arrondissements.
  arrondissement_communes = Commune.where(insee_code: @arrondissements_insee_codes)

  return if arrondissement_communes.empty?

  expert_ids = Expert.joins(:communes)
    .where(communes: { id: arrondissement_communes.select(:id) })
    .distinct.pluck(:id)

  antenne_ids = Antenne.joins(:communes)
    .where(communes: { id: arrondissement_communes.select(:id) })
    .distinct.pluck(:id)

  ApplicationRecord.transaction do
    if expert_ids.any?
      puts "Processing #{expert_ids.count} relevant Experts..."
      Expert.includes(:communes, :territorial_zones).where(id: expert_ids).find_each do |expert|
        process_record(expert)
      end
    end

    if antenne_ids.any?
      puts "Processing #{antenne_ids.count} relevant Antennes..."
      Antenne.includes(:communes, :territorial_zones).where(id: antenne_ids).find_each do |antenne|
        process_record(antenne)
      end
    end
  end
end
