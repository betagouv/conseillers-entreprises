# frozen_string_literal: true

if ENV['RAILS_ENV'] == 'development'
  TEST_PASSWORD = '1234567azeaze122/'
  TEST_EMAIL = 'a@a.a'

  ## Theme and Subject
  theme = Theme.find_or_create_by!(label: 'Test Theme')
  subject = Subject.find_or_create_by!(theme: theme, label: 'Test Subject')

  ## Landings home, themes and subjects
  home_landing = Landing.where(slug: 'home').first_or_create(
    title: 'home'
  )
  landing_theme = home_landing.landing_themes.first_or_create(
    title: "Titre landing theme test",
    slug: "landing-theme-test",
    description: "Description landing theme test",
  )
  landing_subject = landing_theme.landing_subjects.first_or_create(
    subject_id: subject.id,
    title: "Titre landing subject test",
    slug: "landing-subject-test",
    description: "Description landing subject test",
    form_title: "Form Titre landing subject test",
    form_description: "Form Description landing subject test",
    description_explanation: "Description explication landing subject test",
    requires_siret: true,
  )
  ## Institution and Antenne
  institution = Institution.find_or_create_by!(name: 'Test Institution')
  antenne = Antenne.find_or_create_by!(name: 'Test Antenne', institution: institution)
  institution_subject = InstitutionSubject.find_or_create_by!(institution: institution, subject: subject)

  ## User and Expert
  person_params = {
    email: TEST_EMAIL,
    phone_number: '0612345678',
    job: 'Test User',
    full_name: 'Edith Piaf',
    antenne: antenne
  }

  ## User and Expert
  user = User.find_or_create_by!(person_params) do |user|
    user.update!(password: TEST_PASSWORD)
    user.user_right.create!(right: 'admin')
    # users.experts.first is created implicitely
    user.experts.first.experts_subjects.find_or_create_by!(institution_subject: institution_subject)
  end
end

## Region

[
  { name: 'Région Hauts-de-France', bassin_emploi: false, code_region: 32 },
  { name: 'Région Île-de-France', bassin_emploi: false, code_region: 11 },
].each do |option|
  Territory.where(code_region: option[:code_region]).first_or_create(
    name: option[:name],
    bassin_emploi: option[:bassin_emploi]
  )
end
