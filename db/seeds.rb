# frozen_string_literal: true

if ENV['RAILS_ENV'] == 'development'
  TEST_PASSWORD = '1234567'
  TEST_EMAIL = 'a@a.a'

  if Landing.none?
    ## Landing pages
    landing = Landing.find_or_create_by!(slug: 'test-landing', home_sort_order: 0)
    topic = LandingTopic.find_or_create_by!(title: 'Test Topic', landing: landing)
  end

  ## Theme and Subject
  theme = Theme.find_or_create_by!(label: 'Test Theme')
  subject = Subject.find_or_create_by!(theme: theme, label: 'Test Subject')

  ## Institution and Antenne
  institution = Institution.find_or_create_by!(name: 'Test Institution')
  antenne = Antenne.find_or_create_by!(name: 'Test Antenne', institution: institution)
  institution_subject = InstitutionSubject.find_or_create_by!(institution: institution, subject: subject)

  ## User and Expert
  person_params = {
    email: TEST_EMAIL,
    phone_number: '0612345678',
    role: 'Test User',
    full_name: 'Edith Piaf',
    antenne: antenne,
    flags: {
      can_view_diagnoses_tab: true
    }
  }

  ## User and Expert
  user = User.find_or_create_by!(person_params) do |user|
    user.update!(password: TEST_PASSWORD, is_admin: true)
    # users.experts.first is created implicitely
    user.experts.first.experts_subjects.find_or_create_by!(institution_subject: institution_subject)
  end
end

## Region

[
  { name: 'Région Hauts-de-France', bassin_emploi: false, code_region: 32, deployed_at: "2017-07-01".to_datetime },
  { name: 'Région Ile-de-France', bassin_emploi: false, code_region: 11, deployed_at: "2020-12-01".to_datetime },
].each do |option|
  Territory.where(code_region: option[:code_region]).first_or_create(
    name: option[:name],
    bassin_emploi: option[:bassin_emploi],
    deployed_at: option[:deployed_at]
  )
end
