class CreateEmailRetention < ActiveRecord::Migration[7.0]
  def change
    create_table :email_retentions do |t|
      t.references :subject, null: false, foreign_key: true, index: false
      t.references :first_subject, null: false
      t.string :first_subject_label, null: false
      t.references :second_subject, null: false
      t.string :second_subject_label, null: false
      t.string :email_subject, null: false
      t.text :first_paragraph, null: false
      t.integer :waiting_time, null: false

      t.timestamps
    end
    add_index :email_retentions, :subject_id, unique: true
    add_foreign_key :email_retentions, :subjects, column: :first_subject_id, primary_key: :id
    add_foreign_key :email_retentions, :subjects, column: :second_subject_id, primary_key: :id
    add_column :needs, :retention_sent_at, :timestamp, default: nil

    up_only do
      finance_projet = Subject.find(55)
      recruter = Subject.find(44)
      former = Subject.find(45)
      droit_travail = Subject.find(47)
      trouver_clients = Subject.find(49)
      visibilite_internet = Subject.find(120)
      international = Subject.find(51)
      conditions_travail = Subject.find(110)
      ecologie = Subject.find(115)
      gestion_energie = Subject.find(114)
      strategie_rse = Subject.find(137)
      projet_innovation = Subject.find(54)
      inclure_handicap = Subject.find(171)
      emails = [
        {
          waiting_time: 4,
          email_subject: 'Recruter et former',
          first_paragraph: '<p>Il y a quelques mois vous avez utilisé le service public Place des Entreprises pour <strong>financer un projet</strong>.</p><p>D’autres dirigeants cherchant comme vous à financer un projet ont également utilisé ce service pour recruter et faire un point sur leur stratégie.</p>',
          subject: finance_projet,
          first_subject: recruter,
          first_subject_label: 'Recruter un salarié',
          second_subject: former,
          second_subject_label: 'Former un salarié'
        },
        {
          waiting_time: 4,
          email_subject: 'Financer un nouveau projet et être conseillé en droit du travail',
          first_paragraph: '<p>Il y a quelques mois vous avez utilisé le service public Place des Entreprises pour <strong>recruter</strong>.</p><p>D’autres dirigeants cherchant comme vous à recruter un projet ont également utilisé ce service pour fincancer un nouveau projet et être conseillé en droit du travail.</p>',
          subject: recruter,
          first_subject: finance_projet,
          first_subject_label: 'Financer un nouveau projet',
          second_subject: droit_travail,
          second_subject_label: 'Être conseillé en droit du travail'
        },
        {
          waiting_time: 4,
          email_subject: 'Améliorer votre visibilité sur internet et développer votre activité à l’international',
          first_paragraph: '<p>Il y a quelques mois vous avez utilisé le service public Place des Entreprises pour <strong>trouver de nouveaux clients sur internet</strong>.</p><p>D’autres dirigeants cherchant comme vous à trouver de nouveaux clients sur internet ont également utilisé ce service pour améliorer leur visibilité sur internet et développer leur activité à l’international.</p>',
          subject: trouver_clients,
          first_subject: visibilite_internet,
          first_subject_label: 'Améliorer votre visibilité sur internet',
          second_subject: international,
          second_subject_label: 'Développer votre activité à l’international'
        },
        {
          waiting_time: 4,
          email_subject: 'Trouver de nouveaux clients et développer votre activité à l’international',
          first_paragraph: '<p>Il y a quelques mois vous avez utilisé le service public Place des Entreprises pour <strong>améliorer votre visibilité sur internet</strong>.</p><p>D’autres dirigeants cherchant comme vous à améliorer votre visibilité sur internet ont également utilisé ce service pour trouver de nouveaux clients et développer leur activité à l’international.</p>',
          subject: visibilite_internet,
          first_subject: trouver_clients,
          first_subject_label: 'Trouver de nouveaux clients',
          second_subject: international,
          second_subject_label: 'Développer votre activité à l’international'
        },
        {
          waiting_time: 4,
          email_subject: 'Améliorer votre visibilité sur internet et trouver de nouveaux clients',
          first_paragraph: '<p>Il y a quelques mois vous avez utilisé le service public Place des Entreprises pour <strong>développer votre activité à l’international</strong>.</p><p>D’autres dirigeants cherchant comme vous à développer leur activité à l’international ont également utilisé ce service pour améliorer leur visibilité sur internet et trouver de nouveaux clients.</p>',
          subject: international,
          first_subject: visibilite_internet,
          first_subject_label: 'Améliorer votre visibilité sur internet',
          second_subject: trouver_clients,
          second_subject_label: 'Trouver de nouveaux clients'
        },
        {
          waiting_time: 4,
          email_subject: 'Financer un nouveau projet et adapter son activité à la transition écologique',
          first_paragraph: '<p>Il y a quelques mois vous avez utilisé le service public Place des Entreprises pour <strong>amélioration les conditions de travail de vos salariés</strong>.</p><p>D’autres dirigeants cherchant comme vous à amélioration les conditions de travail de leur salariés ont également utilisé ce service pour financer un nouveau projet et adapter leur activité à la transition écologique.</p>',
          subject: conditions_travail,
          first_subject: finance_projet,
          first_subject_label: 'Financer un nouveau projet',
          second_subject: ecologie,
          second_subject_label: 'Adapter son activité à la transition écologique'
        },
        {
          waiting_time: 4,
          email_subject: 'Financer un nouveau projet et développer votre stratégie RSE',
          first_paragraph: '<p>Il y a quelques mois vous avez utilisé le service public Place des Entreprises pour <strong>améliorer votre gestion de l’énergie</strong>.</p><p>D’autres dirigeants cherchant comme vous à amélioration les conditions de travail de leur salariés ont également utilisé ce service pour financer un nouveau projet et développer leur stratégie RSE.</p>',
          subject: gestion_energie,
          first_subject: finance_projet,
          first_subject_label: 'Financer un nouveau projet',
          second_subject: strategie_rse,
          second_subject_label: 'Développer votre stratégie RSE'
        },
        {
          waiting_time: 4,
          email_subject: 'Former un salarié et développer votre activité à l’international',
          first_paragraph: '<p>Il y a quelques mois vous avez utilisé le service public Place des Entreprises pour <strong>réaliser un projet d’innovation</strong>.</p><p>D’autres dirigeants cherchant comme vous à amélioration les conditions de travail de leur salariés ont également utilisé ce service pour former un ou plusieurs salariés et développer leur activité à l’international.</p>',
          subject: projet_innovation,
          first_subject: former,
          first_subject_label: 'Former un salarié',
          second_subject: international,
          second_subject_label: 'Développer votre activité à l’international'
        },
        {
          waiting_time: 4,
          email_subject: 'Amélioration les conditions de travail et inclure le handicap dans votre entreprise',
          first_paragraph: '<p>Il y a quelques mois vous avez utilisé le service public Place des Entreprises pour <strong>être conseillé en droit du travail</strong>.</p><p>D’autres dirigeants cherchant comme vous à amélioration les conditions de travail de leur salariés ont également utilisé ce service pour amélioration les conditions de travail de leurs salariés et inclure le handicap dans votre entreprise.</p>',
          subject: droit_travail,
          first_subject: conditions_travail,
          first_subject_label: 'Amélioration les conditions de travail',
          second_subject: inclure_handicap,
          second_subject_label: 'Inclure le handicap dans votre entreprise'
        }
      ]
      emails.each do |email|
        EmailRetention.create!(
          waiting_time: email[:waiting_time],
          email_subject: email[:email_subject],
          first_paragraph: email[:first_paragraph],
          subject: email[:subject],
          first_subject: email[:first_subject],
          first_subject_label: email[:first_subject_label],
          second_subject: email[:second_subject],
          second_subject_label: email[:second_subject_label]
        )
      end
    end
  end
end
