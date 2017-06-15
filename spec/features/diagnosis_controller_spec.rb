# frozen_string_literal: true

require 'rails_helper'

describe 'diagnosis feature', type: :feature do
  login_user

  before do
    visit '/diagnosis'
    expect(page).not_to have_css 'table.table'

    category = create :category
    question = create :question, category: category

    visit '/diagnosis'
    expect(page).to have_css 'table.table'

    click_link question.label
    expect(page).to have_content 'Aucune aide trouvée...'

    assistance = create :assistance, question: question
    assistance.company.update email: Faker::Internet.email # TODO: Force having an email

    visit '/diagnosis'
    click_link question.label

    expect(page).to have_content 'Une aide a été trouvée'
    expect(page).to have_content assistance.title
    expect(page).to have_content assistance.company.name
    expect(page).to have_content 'Ajouter une visite'

    visit = create :visit, advisor: current_user

    visit '/diagnosis'
    click_link question.label
    click_link "Contacter l'institution par e-mail"

    expect(page).to have_content 'Votre contact en entreprise'

    visitee = create :user
    visit.update visitee: visitee

    visit '/diagnosis'
    click_link question.label

    expect(page).to have_xpath "//a[contains(@href,'mailto:#{assistance.company.email}')]"
  end

  it('has a mailto') {}
end
