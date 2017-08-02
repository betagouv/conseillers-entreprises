# frozen_string_literal: true

require 'rails_helper'

describe 'diagnosis feature', type: :feature do
  login_user

  class DriverJSError < StandardError; end

  after do
    errors = page.driver.browser.manage.logs.get(:browser)
                 .select { |e| e.level == 'SEVERE' }
                 .to_a

    raise DriverJSError, errors.join("\n\n") if errors.present?
  end

  xdescribe 'step-2', js: true, driver: :chrome do
    before do
      visit = create :visit, advisor: current_user
      diagnosis = create :diagnosis, visit: visit
      question = create :question

      visit step_2_diagnosis_path(id: diagnosis.id)

      puts page.body

      save_page
      checkbox_id = "checkbox_#{question.id}"

      checkbox = page.find_by_id(checkbox_id, visible: :all)
      puts "found checkbox : #{!checkbox.nil?}"
      puts "checkbox visible : #{checkbox.visible?}"
      puts "checkbox checked : #{checkbox.checked?}"
      checkbox.click
      puts "and now ? checkbox checked : #{checkbox.checked?}"

      click_button('next_step')
    end

    it 'creates a diagnosed_need' do
      expect(DiagnosedNeed.all.count).to equal(1)
    end
  end
end
