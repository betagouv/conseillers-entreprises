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
      # let!(:match) { create :match, expert: expert_subject.expert, need: need }

      before do
        subjects = create_list(:subject, 4)
        # diagnosis.needs = create_list(:need, 1, diagnosis: diagnosis)
        # diagnosis.save
      end

      it 'display all steps' do
        visit "/analyses/#{ diagnosis.id }"
        expect(page).to have_selector 'h2', text: "Contact de l’entreprise #{diagnosis.company.name}"
        click_button 'diagnosis_submit'

        expect(page).to have_selector 'h1', text: "Besoin exprimé"
        expect(page).to have_current_path(needs_diagnosis_path(diagnosis))

        expect(page).to have_css('input[type=checkbox]:checked', count: 1, visible: false)
        # check('diagnosis_needs_attributes_1__destroy', allow_label_click: true)
        # # find('label[for="diagnosis_needs_attributes_1__destroy"]').click
        # # find('label', text: Subject.first.label, visible: false).click
        # click 'diagnosis_needs_attributes_1__destroy'
        # expect(page).to have_css('input[type=checkbox]:checked', count: 1)
        # Match.create(expert_id: expert_subject.expert.id, need_id: need.id)
        click_button('diagnosis_submit', match: :first)

        expect(page).to have_selector 'h2', text: diagnosis.needs.first.subject.label
        # check(expert_subject.expert.full_name)
        # page.execute_script("document.querySelector('[for=\"diagnosis_needs_attributes_0_matches_attributes_0__destroy\"]').click()")

        # save_and_open_page
        # click_button('diagnosis_submit', match: :first)
        # expect(page).to have_current_path(needs_diagnosis_path(diagnosis))
      end
    end
  end
end