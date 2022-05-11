# frozen_string_literal: true

require 'rails_helper'
require 'system_helper'

describe 'diagnosis', type: :system, js: true do
  login_admin

  describe 'steps' do
    context 'with quo diagnosis' do
      let!(:diagnosis) { create :diagnosis, step: :contact }
      let!(:need) { create :need, diagnosis: diagnosis }
      let!(:expert_subject) do
        create :expert_subject,
               institution_subject: create(:institution_subject, subject: need.subject),
               expert: create(:expert, communes: [need.facility.commune])
      end

      before do
        subjects = create_list(:subject, 4)
      end

      it 'display all steps' do
        visit "/analyses/#{diagnosis.id}"
        expect(page).to have_selector 'h2', text: "Contact de l’entreprise #{diagnosis.company.name}"

        click_button 'diagnosis_submit'

        expect(page).to have_selector 'h1', text: "Besoin exprimé"
        expect(page).to have_current_path(needs_diagnosis_path(diagnosis))

        # On ne peut sélectionner qu'un seul besoin
        expect(page).to have_css('input[type=checkbox]:checked', count: 1, visible: :hidden)
        find('input[type=checkbox]', visible: :hidden, match: :first).set(true)
        expect(page).to have_css('input[type=checkbox]:checked', count: 1, visible: :hidden)
        # check('diagnosis[needs_attributes][0][matches_attributes][0][_destroy]', allow_label_click: true)
        # find('label[for="diagnosis_needs_attributes_1__destroy"]').click
        # find('label', text: Subject.first.label, visible: false).click
        # find('#diagnosis_needs_attributes_1__destroy', visible: false).set(true)
        # click 'diagnosis_needs_attributes_1__destroy'
        # expect(page).to have_css('input[type=checkbox]:checked', count: 1)
        # check(Subject.second.label, allow_label_click: true)
        # expect(page).to have_css('input[type=checkbox]:checked', count: 1, visible: false)
        click_button(I18n.t('next_step'), match: :first)

        expect(page).to have_selector 'h2', text: diagnosis.needs.first.subject.label
        find('label[for="diagnosis_needs_attributes_0_matches_attributes_0__destroy"]').click
        # check('diagnosis[needs_attributes][0][matches_attributes][0][_destroy]', allow_label_click: true)
        # check(Expert.last.full_name, allow_label_click: true)
        # find('.fr-text.bold.fr-m-0', match: :first).click
        # page.check(Expert.last.full_name, allow_label_click: true)
        # check('diagnosis_needs_attributes_0_matches_attributes_0__destroy')
        # find(:xpath, '//*[@id="diagnosis_needs_attributes_0_matches_attributes_0__destroy"]', visible: false, match: :first).set(true)
        # find(:css, '.experts_subject_checkbox', match: :first)

        # check(expert_subject.expert.full_name)
        # page.execute_script("document.querySelector('#diagnosis_needs_attributes_0_matches_attributes_0__destroy').checked = true")

        click_button(I18n.t('diagnoses.steps.matches.notify_matches'), match: :first)
        # save_and_open_page
        expect(page).to have_current_path(conseiller_solicitations_path)
      end
    end
  end
end
