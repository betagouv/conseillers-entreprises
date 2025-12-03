# frozen_string_literal: true

class FixArrondissementTerritorialZones < ActiveRecord::Migration[7.1]
  PARENT_CITY_INSEE_CODES = %w[75056 13055 69123].freeze # Paris, Marseille, Lyon

  def change
    # Find all commune IDs for Paris, Lyon, and Marseille arrondissements.
    arrondissement_insee_pattern = /^(751[01]\d|75120|132[01]\d|13216|6938\d)$/
    arrondissement_communes = Commune.where("insee_code ~ ?", arrondissement_insee_pattern.source)

    return if arrondissement_communes.empty?

    expert_ids = Expert.joins(:communes)
      .where(communes: arrondissement_communes )
      .distinct

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

  private

  def process_record(record)
    arrondissement_communes = record.communes.select { |c| arrondissement?(c.insee_code) }
    return if arrondissement_communes.empty?

    department_codes = arrondissement_communes.map { |c| c.insee_code[0..1] }.uniq
    zones_to_remove = []
    record.territorial_zones.each do |tz|
      # Check if it's a parent city commune zone (ex: Paris 75056)
      if tz.zone_type == 'commune' && PARENT_CITY_INSEE_CODES.include?(tz.code)
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
    insee_code.match?(/^(751[01]\d|75120|132[01]\d|13216|6938\d)$/)
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
end
