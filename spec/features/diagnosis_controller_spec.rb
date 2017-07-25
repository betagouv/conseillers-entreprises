# frozen_string_literal: true

require 'rails_helper'

describe 'diagnosis feature', type: :feature do
  login_user

  describe 'new' do
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

      visitee = create :contact, :with_email
      visit.update visitee: visitee
    end

    it('has a mailto') {}
  end

  xdescribe 'step-2', js: true do
    before do
      visit = create :visit, advisor: current_user
      diagnosis = create :diagnosis, visit: visit

      visit step_2_visit_diagnosis_path(id: diagnosis.id, visit_id: visit.id)

      question = create :question

      check("checkbox_#{question.id}")
      click_button('next_step')
    end

    it 'creates a diagnosed_need' do
      expect(DiagnosedNeed.all.count).to equal(1)
    end
  end
end
