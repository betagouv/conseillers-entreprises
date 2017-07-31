# frozen_string_literal: true

require 'rails_helper'

describe 'diagnosis feature', type: :feature do
  login_user

  xdescribe 'step-2', js: true do
    before do
      visit = create :visit, advisor: current_user
      diagnosis = create :diagnosis, visit: visit

      visit step_2_diagnosis_path(id: diagnosis.id)

      question = create :question

      check("checkbox_#{question.id}")
      click_button('next_step')
    end

    it 'creates a diagnosed_need' do
      expect(DiagnosedNeed.all.count).to equal(1)
    end
  end
end
