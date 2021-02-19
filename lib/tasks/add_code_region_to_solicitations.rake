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
    begin
      siret = FormatSiret.clean_siret(solicitation.siret)
      return if siret.blank?
      searched_etablissement = UseCases::SearchFacility.with_siret(siret)
      ## Si mauvais siret
      return if searched_etablissement.blank?
      code_region = searched_etablissement.etablissement.region_implantation['code']
      solicitation.code_region = code_region
      solicitation.save!(touch: false, validate: false)
    rescue StandardError => e
      return
    end
    total += 1
    volumetry_total += 1
    if volumetry_total % 1999 == 0
      sleep(10.minutes)
      volumetry_total = 0
    end
  end

  puts "#{total} sollicitations mises à jour"
  puts "Sollicitations restant sans code region : #{Solicitation.where(code_region: nil).count}"
end
