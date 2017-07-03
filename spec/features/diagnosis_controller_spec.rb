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

    check("checkbox_#{question.id}")
    click_button('submit_button')

    expect(page).to have_content 'Aucune aide trouvée...'

    expert = create :expert, on_maubeuge: true
    assistance = create :assistance, question: question, experts: [expert]
    assistance.institution.update email: Faker::Internet.email

    visit new_visit_diagnosis_path(visit_id: visit.id)

    check("checkbox_#{question.id}")
    click_button('submit_button')

    expect(page).to have_content 'Une aide a été trouvée'
    expect(page).to have_content assistance.title
    expect(page).to have_content assistance.institution.name
    expect(page).to have_content expert.last_name
    expect(page).to have_content expert.role

    click_link 'Contacter par e-mail'

    expect(page).to have_content 'Votre contact en entreprise'

    visitee = create :contact, :with_email
    visit.update visitee: visitee

    visit new_visit_diagnosis_path(visit_id: visit.id)

    check("checkbox_#{question.id}")
    click_button('submit_button')

    expect(page).to have_xpath "//a[contains(@href,'mailto:#{expert.email}')]"
  end

  it('has a mailto') {}
end
