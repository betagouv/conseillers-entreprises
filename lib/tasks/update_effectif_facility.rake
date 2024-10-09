desc 'update facilities code_effectif'
task update_effectif_facility: :environment do
  puts '## Mise a jour des code effectifs a partir d API entreprise'
  facilities_to_update = Facility.where(code_effectif: [nil, ""]).where.not(siret: nil).where.not(siret: "").order(created_at: :asc).limit(100)
  puts "Etablissements à mettre à jour : #{facilities_to_update.count}"
  total = 0
  # Sur API Entreprise, droit à 2000 requêtes par tranche de 10 minutes par IP
  # on va donc auto-réguler les appels
  volumetry_total = 0
  facilities_to_update.find_each do |facility|
    begin
      p [facility.siret, facility.company.name, I18n.l(facility.company.created_at, format: :ym)]
      effectif_data = Api::ApiEntreprise::EtablissementEffectifMensuel::Base.new(facility.siret).call["effectifs"]
      p effectif_data
      effectif = Effectif::Format.new(effectif_data).effectif
      if effectif.present?
        code_effectif = Effectif::Format.new(effectif_data).code_effectif
        total += 1
      else
        facility.update(code_effectif: 'NR')
      end
    rescue StandardError => e
      next
    end
    volumetry_total += 1
    if volumetry_total % 1900 == 0
      sleep(10.minutes)
      volumetry_total = 0
    end
  end
  puts "#{total} établissements mis à jour"
  puts "Etablissements restant sans code effectif : #{Facility.where(code_effectif: [nil, ""]).count}"
end
