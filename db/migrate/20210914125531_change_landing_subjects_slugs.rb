class ChangeLandingSubjectsSlugs < ActiveRecord::Migration[6.1]
  def up
    LandingSubject.find(45).update(slug: 'mesures-activite-partielle')
    LandingSubject.find(51).update(slug: 'mesures-demarche-ecologie')
    LandingSubject.find(54).update(slug: 'mesures-financement-projet')
    LandingSubject.find(46).update(slug: 'mesures-formation')
    LandingSubject.find(47).update(slug: 'mesures-organisation-du-travail')
    LandingSubject.find(52).update(slug: 'mesures-innovation')
    LandingSubject.find(48).update(slug: 'mesures-recrutement')
    LandingSubject.find(49).update(slug: 'mesures-strategie')
    LandingSubject.find(53).update(slug: 'mesures-tresorerie')
    LandingSubject.find(37).update(slug: 'accompagnement-tresorerie')
    LandingSubject.find(50).update(slug: 'mesures-vente-internet')
    add_index :landing_subjects, :slug, unique: true
    remove_index :landing_subjects, [:slug, :landing_theme_id], :unique => true
  end

  def down
    remove_index :landing_subjects, :slug, unique: true
    add_index :landing_subjects, [:slug, :landing_theme_id], :unique => true
  end
end
