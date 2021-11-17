desc 'update comapnies effectif'
task update_effectif_company: :environment do
  puts '## Mise a jour des effectifs a partir d API entreprise'
  items_to_update = Company.where(code_effectif: nil).where.not(siren: nil).where(created_at: 8.months.ago.at_beginning_of_day..Date.current.at_end_of_day).order(created_at: :asc).limit(500)
  puts "Entreprises à mettre à jour : #{items_to_update.count}"
  total = 0
  # Sur API Entreprise, droit à 2000 requêtes par tranche de 10 minutes par IP
  # on va donc auto-réguler les appels
  volumetry_total = 0
  items_to_update.find_each do |item|
    begin
      p [item.siren, item.name, I18n.l(item.created_at, format: :ym)]
      effectif_data = ApiEntreprise::Entreprise::EffectifMensuel::Base.new(item.siren).call["effectifs"]
      p effectif_data
      effectif = EffectifRange.new(effectif_data).effectif
      if effectif.present?
        code_effectif = EffectifRange.new(effectif_data).code_effectif
        item.update(code_effectif: code_effectif, effectif: effectif)
        total += 1
      else
        item.update(code_effectif: 'NR')
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
  puts "#{total} entreprises mis à jour"
  puts "Entreprises restant sans code effectif : #{Company.where(code_effectif: nil).where.not(siren: nil).count}"
end
