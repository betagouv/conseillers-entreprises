namespace :update_solicitations_code_region do
  desc 'update solicitations code_region from diagnosis'
  task from_diagnosis: :environment do
    days_count = 7
    puts '## Mise a jour des sollicitations a partir des analyses'
    solicitations_to_update = Solicitation.where(created_at: days_count.days.ago..Time.zone.now).where(code_region: nil)
    puts "Sollicitations sans code region des #{days_count} derniers jours : #{solicitations_to_update.count}"
    total = 0
    solicitations_to_update.joins(:diagnosis).find_each do |solicitation|
      code_region = solicitation.diagnosis_regions&.first&.code_region
      if code_region.present?
        SolicitationModification::Update.new(solicitation, code_region: code_region).call!
        total += 1
      end
    end
    puts "#{total} sollicitations mises a jour"
    puts "Sollicitations restant sans code region : #{Solicitation.where(created_at: days_count.days.ago..Time.zone.now).where(code_region: nil).count}"
  end

  desc 'update solicitations code_region from API entreprise'
  task from_api_entreprise: :environment do
    days_count = 7
    puts '## Mise a jour des sollicitations a partir d API entreprise'
    solicitations_to_update = Solicitation.where(created_at: days_count.days.ago..Time.zone.now).where(code_region: nil)
    puts "Sollicitations sans code region : #{solicitations_to_update.count}"
    total = 0
    # Sur API Entreprise, droit à 2000 requêtes par tranche de 10 minutes par IP
    # on va donc auto-réguler les appels
    volumetry_total = 0
    solicitations_to_update.where.not(siret: nil).where.not(siret: "").find_each do |solicitation|
      begin
        etablissement_data = ApiEntreprise::Etablissement::Base.new(solicitation.siret).call
        return if etablissement_data.blank?
        code_region = ApiConsumption::Models::Facility::ApiEntreprise.new(etablissement_data).code_region
        SolicitationModification::Update.new(solicitation, code_region: code_region).call!
        total += 1
      rescue StandardError => e
        next
      end
      volumetry_total += 1
      if volumetry_total % 1999 == 0
        sleep(10.minutes)
        volumetry_total = 0
      end
    end
    puts "#{total} sollicitations mises à jour"
    puts "Sollicitations restant sans code region : #{Solicitation.where(created_at: days_count.days.ago..Time.zone.now).where(code_region: nil).count}"
  end

  task all: %i[from_diagnosis from_api_entreprise]
end

desc 'update solicitations code_region'
task update_solicitations_code_region: %w[update_solicitations_code_region:all]
