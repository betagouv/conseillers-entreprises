# A supprimer une fois la tâche lancée

desc 'update facility readable locality from API entreprise'
task update_facility_readable_locality: :environment do
  puts '## Mise a jour des facility a partir d API entreprise'
  facilities_to_update = Facility.where("length(readable_locality) = 5").limit(10)

  puts "Facilities : #{facilities_to_update.count}"

  total = 0
  # Sur API Entreprise, droit à 2000 requêtes par tranche de 10 minutes par IP
  # on va donc auto-réguler les appels
  volumetry_total = 0
  facilities_to_update.find_each do |f|
    begin
      api_facility = ApiConsumption::Facility.new(f.siret).call
      f.update_columns(readable_locality: api_facility.readable_locality)
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
  puts "#{total} facilities mises à jour"
end
