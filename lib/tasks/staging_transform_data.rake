namespace :staging do
  desc 'Simplify API keys'
  task simplify_api_keys: :environment do
    # on ne manipule pas les données si on est en prod
    if staging_app?
      ApiKey.find(4).update(token: '123456789')
    end
  end

  desc 'refresh data for demo'
  task refresh_demo_data: :environment do
    if staging_app?
      now = Time.zone.now
      @need = Need.find(12683)
      @need.update(created_at: now - 1.day)

      transform_solicitation

      diagnosis = @need.diagnosis
      diagnosis.update({ created_at: now - 1.day, happened_on: now - 1.day, completed_at: now - 1.day })

      Match.find(12025).update({ created_at: now - 1.day, sent_at: now - 1.day })
      Match.find(12026).update({ created_at: now - 1.day, sent_at: now - 1.day })
      Match.find(12027).update({ created_at: now - 1.day, sent_at: now - 1.day })
      Match.find(12028).update({ created_at: now - 1.day, sent_at: now - 1.day })
      Match.find(12029).update({ created_at: now - 1.day, sent_at: now - 1.day })
      Match.find_by({ need_id: @need.id, expert_id: 1632 })&.update({ created_at: now - 1.day, sent_at: now - 1.day })

      Feedback.find(8685).update({ created_at: now - 5.hours })
      Feedback.find(8713).update({ created_at: now - 4.hours })
      Feedback.find(8883).update({ created_at: now - 2.hours })
      Feedback.find(8891).update({ created_at: now - 40.minutes })
      Feedback.find(9212).update({ created_at: now - 15.minutes })
    end
  end

  desc 'Transform data for demo'
  task transform_data_for_demo: :environment do
    # on ne manipule pas les données si on est en prod
    if staging_app?
      @need = Need.find(12683)

      unless @need.visitee.full_name == 'François Cagette'
        transform_visitee
        transform_company
        transform_facility
        transform_solicitation
        transform_diagnosis
        transform_matches
        transform_feedbacks
        add_denis_sauveur
        @need.update(created_at: Time.zone.now)
      end
    end
  end

  def transform_visitee
    visitee = @need.visitee
    visitee.update({
      full_name: 'François Cagette',
      email: 'francois.cagette@beaux-billots.fr',
      phone_number: '0605040302'
    })
  end

  def transform_company
    company = @need.company
    company.update({
      name: 'Beaux Billots',
      siren: '000093548',
      code_effectif: '12'
    })
  end

  def transform_facility
    facility = @need.facility
    facility.update({
      code_effectif: '12',
      siret: '00009354810213',
      naf_libelle: "Fabrication d'emballages en bois",
      naf_code: '1624Z',
      naf_code_a10: 'BE'
    })
  end

  def transform_solicitation
    solicitation = @need.solicitation
    now = Time.zone.now
    solicitation.update({
      created_at: now,
      completed_at: now,
    })
  end

  def transform_diagnosis
    diagnosis = @need.diagnosis
    now = Time.zone.now
    diagnosis.update({
      advisor_id: 10697,
      created_at: now,
      happened_on: now,
      completed_at: now,
      content: "Bonjour, \n\nNous sommes une petite entreprise qui fabrique des emballages en bois. \nNous avons perdus plusieurs gros clients à cause de la crise, nous n’avons plus de rentrée d’argent. Nous allons bientôt ne plus pouvoir payer nos charges qui s’élèvent à 15 000 euros par mois. \nLa banque ne veut pas nous accorder de prêt d’un montant suffisant pour couvrir nos besoins.  \nPouvez-vous nous aider ? \nMerci, \nFrançois Cagette\n"
    })
  end

  def transform_matches
    now = Time.zone.now
    match = Match.find(12025)
    match.update({
      created_at: now - 1.day,
      taken_care_of_at: now,
      closed_at: now,
      archived_at: nil,
      sent_at: now - 1.day,
      status: 'done_not_reachable'
    })
    expert = match.expert
    expert.update({
      full_name: 'Laurent Dubois',
      email: 'l.dubois@cma-hautsdefrance.fr',
      phone_number: '0605040302',
      deleted_at: nil
    })

    match = Match.find(12026)
    match.update({
      created_at: now - 1.day,
      taken_care_of_at: now,
      closed_at: now,
      archived_at: nil,
      sent_at: now - 1.day,
      status: 'done_no_help'
    })
    expert = match.expert
    expert.update({
      full_name: 'Equipe Correspondants Tpe Pas De Calais',
      email: 'tpme_62@banque-france.fr',
      phone_number: '0605040302',
      deleted_at: nil
    })

    match = Match.find(12027)
    match.update({
      created_at: now - 1.day,
      taken_care_of_at: now,
      closed_at: now,
      archived_at: nil,
      sent_at: now - 1.day,
    })
    expert = match.expert
    # Expert personnel, modif doit se faire en 2 temps
    expert.update({
      full_name: 'Djamal Humette',
      phone_number: '0605040302',
      deleted_at: nil
    })
    expert.update(email: 'd.humette@artois.cci.fr')

    match = Match.find(12028)
    match.update({
      created_at: now - 1.day,
      taken_care_of_at: now,
      closed_at: now,
      archived_at: nil,
      sent_at: now - 1.day,
      status: 'not_for_me'
    })
    expert = match.expert
    # Expert personnel, modif doit se faire en 2 temps
    expert.update({
      full_name: 'Brigitte Tonot',
      phone_number: '0605040302',
      deleted_at: nil
    })
    expert.update(email: 'brigitte.tonot@hautsdefrance.fr')

    match = Match.find(12029)
    match.update({
      created_at: now - 1.day,
      taken_care_of_at: nil,
      closed_at: nil,
      archived_at: nil,
      sent_at: now - 1.day,
      status: 'quo'
    })
    expert = match.expert
    expert.update({
      full_name: 'Equipe DDFIP 62 - Pierrette Brindy et Mahmoud Kabann',
      email: "ddfip.62.actioneconomique.pgp@dgfip.finances.gouv.fr",
      phone_number: '0605040302',
      deleted_at: nil
    })
  end

  def transform_feedbacks
    feedback = Feedback.find(8685)
    feedback.update(description: "Entreprise en plan de continuation. Refus de PGE avec échec de la médiation du crédit. Orienté vers la saisine du CODEFI Pas de Calais.")
    feedback.user.update({
      full_name: 'Latifa Gault',
      email: 'latifa.gault@banque-france.fr',
      phone_number: '0605040302',
      deleted_at: nil
    })

    # Utilisation de find_by, au cas où il aurait déjà été supprimé
    Feedback.find_by(id: 8694)&.destroy

    feedback = Feedback.find(8713)
    feedback.update(description: "L'entreprise intervient essentiellement en qualité de sous-traitant de 2ème rang, dans le cadre de marchés publics initiés par des collectivités territoriales. Après l'ouverture d'une RJ en 2019, le TC  d'Arras a décidé d'un plan de continuation au bénéfice de l'entreprise en octobre 2020. Les difficultés de l'entreprise pré existent donc à la crise covid et prendraient naissance dans la faiblesse des marges commerciales réalisées en raison de son positionnement sur ce secteur d'activités, malgré la compétence reconnue. \nFace à cette problématique, l'entrepreneur a tenté de prendre des contrats hors de la région Nord ,en Charentes, contrats qui se sont révélées infructueux et ont accru les tensions de trésorerie. Une dette vis-à-vis du factor a également fragilisé la trésorerie ces derniers temps mais est en passe d'être résorbée.")
    feedback.user.update({
      full_name: 'Pierrette Brindy',
      email: 'pierrette.brindy@dgfip.finances.gouv.fr',
      phone_number: '0605040302',
      deleted_at: nil
    })

    feedback = Feedback.find(8883)
    feedback.update(description: "L'entreprise a obtenu une avance remboursable du fonds de relance de la CAHC de 10 000 €.")
    feedback.user.update({
      full_name: 'Djamal Humette',
      email: 'd.humette@artois.cci.fr',
      phone_number: '0605040302',
      deleted_at: nil
    })

    Feedback.find(8891).update(description: "Face à l'urgence de la situation (règlement des salaires), le mandataire a conseillé  à M. Cagette de déposer un dossier de demande de liquidation de l'entreprise.\nSeule une mesure rapide de prêt permettrait d'éviter cette dissolution et la mise au chômage des salariés. M. Cagette indique ne plus disposer de suffisamment de temps pour remonter des dossiers de demande d'une hypothétique aide.")

    feedback = Feedback.find(9212)
    feedback.update(description: "Situation prise en charge par les partenaires")
    feedback.user.update({
      full_name: 'Brigitte Tonneau',
      email: 'brigitte.tonneau@hautsdefrance.fr',
      phone_number: '0605040302',
      deleted_at: nil
    })
  end

  def add_denis_sauveur
    expert = Expert.find(1632)
    Match.create({
      need_id: @need.id,
      subject_id: 42,
      expert_id: expert.id,
      sent_at: Time.zone.now
    })
    expert.institution = Institution.find(80)
    expert.antenne.update(name: 'Urssaf Démo')
  end

  def staging_app?
    Rails.env.production? && ((ENV.fetch('STAGING_ENV', 'false')) == 'true')
  end

  desc 'transform data for staging'
  task transform_data: %w[transform_data_for_demo simplify_api_keys]
end
