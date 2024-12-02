class CreateCooperations < ActiveRecord::Migration[7.0]
  def change
    create_table :cooperations do |t|
      t.string :name
      t.string :mtm_campaign
      t.string :url
      t.boolean :display_url, default: false
      t.references :institution, null: false, foreign_key: true, index: true

      t.timestamps
    end

    create_table :cooperation_themes do |t|
      t.references :cooperation, null: false, foreign_key: true, index: true
      t.references :theme, null: false, foreign_key: true, index: true

      t.timestamps
    end

    add_reference :landings, :cooperation, foreign_key: true
    remove_column :themes, :cooperation, :boolean, default: false

    up_only do
      ## Entreprendre Service Public
      p "Entreprendre Service Public"
      institution = Institution.find_by(slug: 'dila')
      cooperation = institution.cooperations.create!(name: "Entreprendre", url: 'https://entreprendre.service-public.fr', mtm_campaign: 'entreprendre', display_url: true)
      cooperation.landings.push(Landing.find_by(slug: 'entreprendre-service-public-fr'))
      cooperation.create_logo(name: 'Entreprendre', filename: 'entreprendre')

      ## Mon entreprise - URSSAF
      p "Mon entreprise - URSSAF"
      institution = Institution.find_by(slug: 'urssaf')
      cooperation = institution.cooperations.create!(name: "Mon entreprise", url: 'https://mon-entreprise.urssaf.fr')
      ['activite-partielle-mon-entreprise-urssaf-fr', 'mon-entreprise-urssaf-fr', 'rh-mon-entreprise-urssaf-fr', 'professions-liberales-mon-entreprise-urssaf-fr','rh-simulateur-urssaf-fr'].each do |slug|
        cooperation.landings.push(Landing.find_by(slug: slug))
      end
      cooperation.create_logo(name: 'Mon entreprise', filename: 'mon-entreprise-urssaf')

      ## « les-aides-fr » - institution CCI
      p "les-aides-fr"
      institution = Institution.find_by(slug: 'cci')
      cooperation = institution.cooperations.create!(name: "Les-aides.fr", url: 'https://les-aides.fr', display_url: true)
      cooperation.landings.push(Landing.find_by(slug: 'cci-les-aides-fr'))
      cooperation.create_logo(name: 'Les aides', filename: 'les-aides-cci')

      ## « mission transition écologique des entreprises » - institution Ademe
      p "mission transition ecologique des entreprises"
      institution = Institution.find_by(slug: 'ministere_de_la_transition_ecologique_et_solidaire_acquisition')
      cooperation = institution.cooperations.create!(name: "Mission transition écologique des entreprises", url: 'https://mission-transition-ecologique.beta.gouv.fr', display_url: true)
      ['france-transition-ecologique', 'transition-ecologique-entreprises-api'].each do |slug|
        cooperation.landings.push(Landing.find_by(slug: slug))
      end
      cooperation.create_logo(name: 'Mission transition ecologique', filename: 'transition-ecologique')

      ## « entreprises.gouv.fr » - institution DGE
      p "entreprises.gouv.fr"
      institution = Institution.find_by(slug: 'dge')
      cooperation = institution.cooperations.create!(name: "entreprises.gouv.fr", url: 'https://www.entreprises.gouv.fr/fr/la-direction-generale-des-entreprises-dge')
      cooperation.landings.push(Landing.find_by(slug: 'dge'))
      cooperation.create_logo(name: 'Entreprise Gouv', filename: 'ministere-economie-finances')

      ## « espace fournisseurs MEF » - institution Secrétariat général des ministères économiques et financiers
      p "espace fournisseurs MEF"
      institution = Institution.find_by(slug: 'sg-mef')
      cooperation = institution.cooperations.create!(name: "Espace fournisseurs MEF", url: 'https://www.economie.gouv.fr', display_url: true)
      cooperation.landings.push(Landing.find_by(slug: 'espace-fournisseurs'))
      cooperation.cooperation_themes.create!(theme: Theme.find_by(label: "Problématiques des fournisseurs des ministères économiques et financiers"))
      cooperation.create_logo(name: 'Ministère Economie Finance', filename: 'ministere-economie-finances')

      ## « zetwal » - institution Agence de développement (antenne Martinique Développement)
      p "zetwal"
      institution = Institution.find_by(slug: 'collectivite-de-martinique')
      cooperation = institution.cooperations.create!(name: "Zetwal", url: 'https://www.zetwal.mq', display_url: true)
      ['zetwal', 'zetwal-crise'].each do |slug|
        cooperation.landings.push(Landing.find_by(slug: slug))
      end
      cooperation.cooperation_themes.create!(theme: Theme.find_by(label: "Problématiques de crise"))
      cooperation.create_logo(name: 'Zetwal', filename: 'zetwal')

      ## « Entreprises en Pays de la Loire » - institution CCI
      p "Entreprises en Pays de la Loire"
      institution = Institution.find_by(slug: 'cci')
      cooperation = institution.cooperations.create!(name: "Entreprises en Pays de la Loire", url: 'https://entreprisespaysdelaloire.fr')
      cooperation.landings.push(Landing.find_by(slug: 'cci-pays-de-la-loire'))
      cooperation.create_logo(name: 'Entreprises en Pays de la Loire', filename: 'entreprises-pays-loire')

      ## « Espace organisme de formation AURA » - institution DREETS
      p "Espace organisme de formation AURA"
      institution = Institution.find_by(slug: 'dreets')
      cooperation = institution.cooperations.create!(name: "Espace organismes de formation - Dreets AURA", url: 'https://auvergne-rhone-alpes.dreets.gouv.fr/Declaration-des-organismes-de-formation-professionnelle')
      cooperation.landings.push(Landing.find_by(slug: 'espace-organisme-formation-dreets-aura'))
      cooperation.cooperation_themes.create!(theme: Theme.find_by(label: "Problématiques des organismes de formation"))
      cooperation.create_logo(name: 'Dreets', filename: 'dreets')

      ## « Team RH Occitanie » - institution DREETS
      p "Team RH Occitanie"
      institution = Institution.find_by(slug: 'dreets')
      cooperation = institution.cooperations.create!(name: "Team RH Occitanie", url: 'https://www.teamrh-occitanie.fr')
      cooperation.landings.push(Landing.find_by(slug: 'team-rh-occitanie'))
      cooperation.cooperation_themes.create!(theme: Theme.find_by(label: "Problématiques de ressources humaines"))
      cooperation.create_logo(name: 'Team RH Occitanie', filename: 'team-rh-occitanie')

      ## « Les entreprises s’engagent » - institution France Travail
      p "Les entreprises s’engagent"
      institution = Institution.find_by(slug: 'dreets')
      cooperation = institution.cooperations.create!(name: "Les entreprises s’engagent", url: 'https://lesentreprises-sengagent.gouv.fr')
      cooperation.landings.push(Landing.find_by(slug: 'les-entreprises-s-engagent'))
      cooperation.cooperation_themes.create!(theme: Theme.find_by(label: "Problématiques des entreprises qui s'engagent"))
      cooperation.create_logo(name: 'Les entreprises s’engagent', filename: 'entreprises-s-engagent')

      ## « Portail des travailleurs independants handicapes » - institution Urssaf
      p "Portail des travailleurs independants handicapes"
      institution = Institution.find_by(slug: 'urssaf')
      cooperation = institution.cooperations.create!(name: "Portail des travailleurs indépendants handicapés", url: nil)
      cooperation.landings.push(Landing.find_by(slug: 'portail-des-travailleurs-independants-handicapes'))
      cooperation.cooperation_themes.create!(theme: Theme.find_by(label: "Problématiques des travailleurs indépendants handicapés"))

      ## « Portail RSE » - institution DGE
      p "Portail RSE"
      institution = Institution.find_by(slug: 'dge')
      cooperation = institution.cooperations.create!(name: "Portail RSE", url: 'https://portail-rse.beta.gouv.fr')
      cooperation.landings.push(Landing.find_by(slug: 'impact-gouv'))

      ## « Portail Maisons des professions libérales » - institution Maisons des professions libérales
      p "Portail Maisons des professions libérales"
      institution = Institution.find_by(slug: 'unapl')
      cooperation = institution.cooperations.create!(name: "Portail Maisons des professions libérales", url: nil)
      cooperation.landings.push(Landing.find_by(slug: 'maison-des-professions-liberales'))
    end
  end
end

# up_only do
#   cooperation_labels = [
#     "Brexit","Problématiques des travailleurs indépendants handicapés","Problématiques de ressources humaines",
#     "Problématiques des fournisseurs des ministères économiques et financiers","Problématiques des organismes de formation"
#   ]
#   Theme.where(label: cooperation_labels).update_all(cooperation: true)
# end

# up_only do
#   # "Problématiques de ressources humaines" -> Occitanie
#   # "Problématiques des organismes de formation" -> Aura
#   [
#     { theme: 55, region: 133 },
#     { theme: 53, region: 137 },
#   ].each do |hash|
#     Theme.find(hash[:theme]).territories << Territory.find(hash[:region])
#   end
# end
# cf https://github.com/betagouv/conseillers-entreprises/pull/3612/files

# Landing.where(display_partner_url: true).pluck(:slug)
# => ["entreprendre-service-public-fr", "cci-les-aides-fr", "espace-fournisseurs", "team-rh-occitanie", "transition-ecologique-entreprises-api", "zetwal"]
