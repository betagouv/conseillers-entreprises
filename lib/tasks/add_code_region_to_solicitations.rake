task add_code_region_to_solicitations: :environment do
  puts 'Mise à jour des sollicitations'

  puts "Sollicitations sans code region : #{Solicitation.where(code_region: nil).count}"
  total = 0
  # Sur API Entreprise, droit à 2000 requêtes par tranche de 10 minutes par IP
  # on va donc auto-réguler les appels
  volumetry_total = 0
  # Pour gagner un peu de temps :
  Solicitation.where(code_region: nil).joins(:diagnosis).each do |solicitation|
    code_region = solicitation.diagnosis_region&.first&.code_region
    solicitation.update(code_region: code_region) if code_region.present?
    total += 1
  end
  Solicitation.where(code_region: nil).find_each do |solicitation|
    solicitation.set_code_region
    solicitation.save!(touch: false, validate: false)
    total += 1
    volumetry_total += 1
    if volumetry_total % 2000 == 0
      sleep(10.minutes)
      volumetry_total = 0
    end
  end

  puts "#{total} sollicitations mises à jour"
  puts "Sollicitations restant code region : #{Solicitation.where(code_region: nil).count}"
end
