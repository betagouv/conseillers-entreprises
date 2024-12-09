class CreateCooperations < ActiveRecord::Migration[7.0]
  def change
    create_table :cooperations do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :root_url
      t.string :mtm_campaign
      t.datetime :archived_at, precision: nil
      t.boolean :display_url, default: false
      t.boolean :display_pde_partnership_mention, default: false
      t.references :institution, null: false, foreign_key: true, index: true

      t.timestamps
    end

    create_table :cooperation_themes do |t|
      t.references :cooperation, null: false, foreign_key: true, index: true
      t.references :theme, null: false, foreign_key: true, index: true

      t.timestamps
    end

    add_reference :landings, :cooperation, foreign_key: true, index: true
    add_reference :solicitations, :cooperation, foreign_key: true, index: true

    up_only do
      generate_cooperations
      update_solicitations
      Landing.update_all(partner_url: nil)
    end

    rename_column :landings, :partner_url, :url_path
    remove_column :landings, :display_partner_url, :boolean, default: false
    remove_column :landings, :display_pde_partnership_mention, :boolean, default: false
    remove_reference :landings, :institution, foreign_key: true, index: true
    remove_reference :solicitations, :institution, foreign_key: true, index: true
    remove_column :themes, :cooperation, :boolean, default: false
  end

  def generate_cooperations
    ## Entreprendre Service Public
    p "Entreprendre Service Public"
    institution = Institution.find_by(slug: 'dila')
    cooperation = institution.cooperations.create!(name: "Entreprendre", root_url: 'https://entreprendre.service-public.fr', mtm_campaign: 'entreprendre', display_url: true)
    cooperation.landings.push(Landing.find_by(slug: 'entreprendre-service-public-fr'))
    cooperation.create_logo(name: 'Entreprendre', filename: 'entreprendre')

    Solicitation.mtm_campaign_eq('entreprendre').update_all(cooperation_id: cooperation.id)

    ## Mon entreprise - URSSAF
    p "Mon entreprise - URSSAF"
    institution = Institution.find_by(slug: 'urssaf')
    cooperation = institution.cooperations.create!(name: "Mon entreprise", root_url: 'https://mon-entreprise.urssaf.fr', display_pde_partnership_mention: true)
    ['activite-partielle-mon-entreprise-urssaf-fr', 'mon-entreprise-urssaf-fr', 'rh-mon-entreprise-urssaf-fr', 'professions-liberales-mon-entreprise-urssaf-fr','rh-simulateur-urssaf-fr'].each do |slug|
      cooperation.landings.push(Landing.find_by(slug: slug))
    end
    cooperation.create_logo(name: 'Mon entreprise', filename: 'mon-entreprise-urssaf')

    ## « les-aides-fr » - institution CCI
    p "les-aides-fr"
    institution = Institution.find_by(slug: 'cci')
    cooperation = institution.cooperations.create!(name: "Les-aides.fr", root_url: 'https://les-aides.fr', display_url: true)
    cooperation.landings.push(Landing.find_by(slug: 'cci-les-aides-fr'))
    cooperation.create_logo(name: 'Les aides', filename: 'les-aides-cci')

    ## « mission transition écologique des entreprises » - institution Ademe
    p "mission transition ecologique des entreprises"
    institution = Institution.find_by(slug: 'ministere_de_la_transition_ecologique_et_solidaire_acquisition')
    cooperation = institution.cooperations.create!(name: "Mission transition écologique des entreprises", root_url: 'https://mission-transition-ecologique.beta.gouv.fr', display_url: true, display_pde_partnership_mention: true)
    ['france-transition-ecologique', 'transition-ecologique-entreprises-api'].each do |slug|
      cooperation.landings.push(Landing.find_by(slug: slug))
    end
    cooperation.create_logo(name: 'Mission transition ecologique', filename: 'transition-ecologique')

    ## « entreprises.gouv.fr » - institution DGE
    p "entreprises.gouv.fr"
    institution = Institution.find_by(slug: 'dge')
    cooperation = institution.cooperations.create!(name: "entreprises.gouv.fr", root_url: 'https://www.entreprises.gouv.fr/fr/la-direction-generale-des-entreprises-dge')
    cooperation.landings.push(Landing.find_by(slug: 'dge'))
    cooperation.create_logo(name: 'Entreprise Gouv', filename: 'ministere-economie-finances')

    ## « espace fournisseurs MEF » - institution Secrétariat général des ministères économiques et financiers
    p "espace fournisseurs MEF"
    institution = Institution.find_by(slug: 'sg-mef')
    cooperation = institution.cooperations.create!(name: "Espace fournisseurs MEF", root_url: 'https://www.economie.gouv.fr', display_url: true, display_pde_partnership_mention: true)
    cooperation.landings.push(Landing.find_by(slug: 'espace-fournisseurs'))
    cooperation.cooperation_themes.create!(theme: Theme.find_by(label: "Problématiques des fournisseurs des ministères économiques et financiers"))
    cooperation.create_logo(name: 'Ministère Economie Finance', filename: 'ministere-economie-finances')

    ## « zetwal » - institution Agence de développement (antenne Martinique Développement)
    p "zetwal"
    institution = Institution.find_by(slug: 'collectivite-de-martinique')
    cooperation = institution.cooperations.create!(name: "Zetwal", root_url: 'https://www.zetwal.mq', display_url: true, display_pde_partnership_mention: true)
    ['zetwal', 'zetwal-crise'].each do |slug|
      cooperation.landings.push(Landing.find_by(slug: slug))
    end
    cooperation.cooperation_themes.create!(theme: Theme.find_by(label: "Problématiques de crise"))
    cooperation.create_logo(name: 'Zetwal', filename: 'zetwal')

    ## « Entreprises en Pays de la Loire » - institution CCI
    p "Entreprises en Pays de la Loire"
    institution = Institution.find_by(slug: 'cci')
    cooperation = institution.cooperations.create!(name: "Entreprises en Pays de la Loire", root_url: 'https://entreprisespaysdelaloire.fr', display_pde_partnership_mention: true)
    cooperation.landings.push(Landing.find_by(slug: 'cci-pays-de-la-loire'))
    cooperation.create_logo(name: 'Entreprises en Pays de la Loire', filename: 'entreprises-pays-loire')

    ## « Espace organisme de formation AURA » - institution DREETS
    p "Espace organisme de formation AURA"
    institution = Institution.find_by(slug: 'dreets')
    cooperation = institution.cooperations.create!(name: "Espace organismes de formation - Dreets AURA", root_url: 'https://auvergne-rhone-alpes.dreets.gouv.fr/Declaration-des-organismes-de-formation-professionnelle', display_pde_partnership_mention: true)
    cooperation.landings.push(Landing.find_by(slug: 'espace-organisme-formation-dreets-aura'))
    cooperation.cooperation_themes.create!(theme: Theme.find_by(label: "Problématiques des organismes de formation"))
    cooperation.create_logo(name: 'Dreets', filename: 'dreets')

    ## « Team RH Occitanie » - institution DREETS
    p "Team RH Occitanie"
    institution = Institution.find_by(slug: 'dreets')
    cooperation = institution.cooperations.create!(name: "Team RH Occitanie", root_url: 'https://www.teamrh-occitanie.fr', display_url: true, display_pde_partnership_mention: true)
    cooperation.landings.push(Landing.find_by(slug: 'team-rh-occitanie'))
    cooperation.cooperation_themes.create!(theme: Theme.find_by(label: "Problématiques de ressources humaines"))
    cooperation.create_logo(name: 'Team RH Occitanie', filename: 'team-rh-occitanie')

    ## « Les entreprises s’engagent » - institution France Travail
    p "Les entreprises s’engagent"
    institution = Institution.find_by(slug: 'france-travail-pro')
    cooperation = institution.cooperations.create!(name: "Les entreprises s’engagent", root_url: 'https://lesentreprises-sengagent.gouv.fr')
    cooperation.landings.push(Landing.find_by(slug: 'les-entreprises-s-engagent'))
    cooperation.cooperation_themes.create!(theme: Theme.find_by(label: "Problématiques des entreprises qui s'engagent"))
    cooperation.create_logo(name: 'Les entreprises s’engagent', filename: 'entreprises-s-engagent')

    ## « Portail des travailleurs independants handicapes » - institution Urssaf
    p "Portail des travailleurs independants handicapes"
    institution = Institution.find_by(slug: 'urssaf')
    cooperation = institution.cooperations.create!(name: "Portail des travailleurs indépendants handicapés", root_url: nil)
    cooperation.landings.push(Landing.find_by(slug: 'portail-des-travailleurs-independants-handicapes'))
    cooperation.cooperation_themes.create!(theme: Theme.find_by(label: "Problématiques des travailleurs indépendants handicapés"))

    ## « Portail RSE » - institution DGE
    p "Portail RSE"
    institution = Institution.find_by(slug: 'dge')
    cooperation = institution.cooperations.create!(name: "Portail RSE", root_url: 'https://portail-rse.beta.gouv.fr', display_pde_partnership_mention: true)
    cooperation.landings.push(Landing.find_by(slug: 'impact-gouv'))

    ## « Portail Maisons des professions libérales » - institution Maisons des professions libérales
    p "Portail Maisons des professions libérales"
    institution = Institution.find_by(slug: 'unapl')
    cooperation = institution.cooperations.create!(name: "Portail Maisons des professions libérales", root_url: nil)
    cooperation.landings.push(Landing.find_by(slug: 'maison-des-professions-liberales'))

    ## ARCHIVES
    p "Entreprises ma région Sud"
    institution = Institution.find_by(slug: 'conseil_regional_de_provence_alpes_cotes_d_azur')
    landing = Landing.find_by(slug: 'entreprises-ma-region-sud')
    cooperation = institution.cooperations.create!(name: "Entreprises ma région Sud", root_url: 'https://entreprises.maregionsud.fr', archived_at: landing.archived_at)
    cooperation.landings.push(landing)

    p "Entreprises Haut de France"
    institution = Institution.find_by(slug: 'conseil-regional-des-hauts-de-france')
    landing = Landing.find_by(slug: 'entreprises-haut-de-france')
    cooperation = institution.cooperations.create!(name: "Entreprises Haut de France", root_url: 'https://entreprises.hautsdefrance.fr/Contact', archived_at: landing.archived_at)
    cooperation.landings.push(landing)

    p "Brexit"
    institution = Institution.find_by(slug: 'douanes')
    landing = Landing.find_by(slug: 'brexit')
    cooperation = institution.cooperations.create!(name: "Brexit", root_url: 'https://brexit.hautsdefrance.fr', archived_at: landing.archived_at)
    cooperation.landings.push(landing)

    p "Relance Hauts de France"
    institution = Institution.find_by(slug: 'conseil-regional-des-hauts-de-france')
    landing = Landing.find_by(slug: 'relance-hautsdefrance')
    cooperation = institution.cooperations.create!(name: "Relance Hauts de France", root_url: nil, archived_at: landing.archived_at)
    cooperation.landings.push(landing)
  end

  def update_solicitations
    ## Mise à jour des sollicitations
    p "Mise à jour des sollicitations"

    cooperation = Cooperation.find_by(name: "Entreprendre")
    Solicitation.mtm_campaign_eq('entreprendre').update_all(cooperation_id: cooperation.id)

    Cooperation.find_each do |cooperation|
      Solicitation.joins(landing: :cooperation).where(landing: { cooperation_id: cooperation.id }).update_all(cooperation_id: cooperation.id)
    end
  end
end
