class AddDescriptionPrefillToLandingSubjects < ActiveRecord::Migration[7.0]
  def change
    add_column :landing_subjects, :description_prefill, :text

    up_only do
      [
        { slug: "recruter",prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de...\r\n\r\nJe cherche à recruter sur un poste de ...\r\n\r\nL'offre est connue de Pôle Emploi : oui/non\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "handicap-entreprise", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de...\r\n\r\nJe cherche à recruter sur un poste de ...\r\n\r\nJe souhaiterais aussi des conseils sur ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "former", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJ'aimerais former mes salariés sur ...\r\n\r\nLe but est ... \r\n\r\nLe nombre de salariés concernés est ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "organisation-du-travail", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\n Le but de ma démarche est...\r\n\r\nJ’ai besoin de conseils sur ... \r\n\r\nMerci d'avance pour votre appel" },
        { slug: "conseil-retraite", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJ'aimerais avoir des conseils pour ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "financer-projet", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJ'aimerais investir pour ... \r\n\r\nLe coût global du projet est de ... \r\n\r\nMon besoin de financement s’élève à ...\r\n\r\nConcernant ma banque, ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "reduction-impots", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nElle existe depuis ... \r\n\r\nJe souhaiterais des conseils sur ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "projet-innovation",  prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nL’innovation concerne ...\r\n\r\nMon besoin de financement s'élève à ... \r\n\r\nConcernant ma banque,...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "projet-immobilier",  prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJ'ai pour projet d'installer à ... \r\n\r\nLe coût global s’élève à...\r\n\r\nLe bâtiment appartiendra à ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "diagnostic",  prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJ'aimerais faire le point car...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "tresorerie",  prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJe rencontre actuellement des difficultés car...\r\n\r\nLe montant de mon besoin de trésorerie s’élève à ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "litige", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJe rencontre actuellement un différend avec ...\r\n\r\n Ce différend date de ...\r\n\r\nLe montant de la créance s'élève à...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "droit-du-travail", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nMa question porte sur...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "activite-partielle", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJ'envisage l'activité partielle car ...\r\n\r\nLe nombre de salariés concernés est de ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "preparer-le-depart-ou-la-reconversion-de-salaries", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJe m’interroge sur le départ de salariés car ...\r\n\r\nJ’ai besoin de conseils sur ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "strategie", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJ'aimerais faire un point sur la stratégie de l'entreprise car ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "nouvelle-offre-produit-service", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJ'aimerais développer une nouvelle offre car ...\r\n\r\nMon but est ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "clients", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJ'aimerais trouver de nouveaux clients car ...\r\n\r\nJ’envisage de cibler ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "international", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJe souhaite me développer à ...\r\n\r\nJ'aimerais être accompagné sur ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "vendre-sur-internet", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nElle existe depuis ... \r\n\r\nActuellement, ma présence sur internet est ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "visibilite-sur-internet", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nElle existe depuis ... \r\n\r\nActuellement, j’ai déjà sur internet ...\r\n\r\nL'adresse de mon site : ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "proteger-vos-donnees", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nElle existe depuis ... \r\n\r\nJe souhaite des conseils sur ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "demarche-ecologie", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJ'ai pour projet de ... \r\n\r\nJ'aimerais être accompagné sur ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "energie",  prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJ'ai pour projet de ... \r\n\r\nJ'aimerais être accompagné sur ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "dechets",  prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJ'ai pour projet de ... \r\n\r\nJ'aimerais être accompagné sur ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "eau", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nActuellement, j’utilise de l’eau pour ...\r\n\r\nJ'ai pour projet de ... \r\n\r\nJ'aimerais être accompagné sur ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "transport-mobilite", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJ'ai pour projet de ... \r\n\r\nJ'aimerais être accompagné sur ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "bilan-rse", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nLe but de notre démarche RSE est ... \r\n\r\nJ'aimerais être accompagné sur ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "obligations-sante-securite", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nNous avons déjà mis en place ...\r\n\r\nJ'aimerais être accompagné sur ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "qualite-de-vie-au-travail", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJ'aimerais améliorer les conditions de travail pour ...\r\n\r\n J’ai besoin d’aide sur ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "former-risques-professionnels", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nLes principaux risques identifiés sont ...\r\n\r\nNous souhaitons former des salariés sur ...\r\n\r\nLe nombre de salariés concernés est ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "vendre-entreprise", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nSon effectif est de ...\r\n\r\nJe souhaite céder mon entreprise car ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "reprendre-entreprise", prefill: "Bonjour,\r\n\r\nJ'aimerais reprendre une entreprise dans le secteur de ...\r\n\r\nJ’ai de l’expérience professionnelle dans... \r\n\r\nJe peux faire un apport de ... \r\n\r\nConcernant les entreprises en difficultés, ... \r\n\r\nMerci d'avance pour votre appel" },
        { slug: "formalites-entreprise", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nLe statut de l’entreprise est ...\r\n\r\nJe souhaite être conseillé sur...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "declaration-organisme-formation", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nMon projet est ...\r\n\r\nJ'aimerais être accompagné pour ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "agrement-esus",  prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nMon activité est d’utilité sociale car ...\r\n\r\nJe m’interroge sur ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "autre-demande",  prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJe vous contacte car ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "realiser-un-diagnostic-pour-reduire-votre-consommation-d-energie", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJ'ai pour projet de ... \r\n\r\nJ'aimerais être accompagné sur ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "financer-vos-investissements-pour-reduire-votre-consommation-d-energie", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJ'aimerais investir pour ... \r\n\r\nLe coût global du projet est de ... \r\n\r\nMon besoin de financement s’élève à ...\r\n\r\nConcernant ma banque, ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "s-informer-sur-l-activite-partielle-pour-faire-face-au-contexte-energetique", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJ'envisage l'activité partielle car ...\r\n\r\nLe nombre de salariés concernés est de ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "resoudre-des-difficultes-financieres-liees-a-l-augmentation-des-prix-de-l-energie", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJe rencontre actuellement des difficultés car...\r\n\r\nLe montant de mon besoin de trésorerie s’élève à ...\r\n\r\nMerci d'avance pour votre appel" },
        { slug: "resoudre-un-differend-avec-votre-fournisseur-d-energie", prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de ...\r\n\r\nJe rencontre actuellement un différend avec ...\r\n\r\n Ce différend date de ...\r\n\r\nLe montant de la créance s'élève à...\r\n\r\nMerci d'avance pour votre appel" },
      ].each do |item|
        LandingSubject.find_by(slug: item[:slug])&.update(description_prefill: item[:prefill])
      end
    end
  end
end
