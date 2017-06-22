# frozen_string_literal: true

require 'rails_helper'

describe 'diagnosis feature', type: :feature do
  login_user

  before do
    visit = create :visit, advisor: current_user

    visit new_visit_diagnosis_path(visit_id: visit.id)
    expect(page).not_to have_css 'table.table'

    category = create :category
    question = create :question, category: category

    visit new_visit_diagnosis_path(visit_id: visit.id)
    expect(page).to have_css 'table.table'

    click_link question.label
    expect(page).to have_content 'Aucune aide trouvée...'

    assistance = create :assistance, question: question
    assistance.institution.update email: Faker::Internet.email # TODO: Force having an email

    visit new_visit_diagnosis_path(visit_id: visit.id)
    click_link question.label

    expect(page).to have_content 'Une aide a été trouvée'
    expect(page).to have_content assistance.title
    expect(page).to have_content assistance.institution.name

    click_link "Contacter l'institution par e-mail"

    expect(page).to have_content 'Votre contact en entreprise'

    visitee = create :contact, :with_email
    visit.update visitee: visitee

    visit new_visit_diagnosis_path(visit_id: visit.id)
    click_link question.label

    expect(page).to have_xpath "//a[contains(@href,'mailto:#{assistance.institution.email}')]"
  end

  it('has a mailto') {}
end
