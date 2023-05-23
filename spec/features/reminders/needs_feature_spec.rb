# frozen_string_literal: true

require 'rails_helper'

describe 'reminders needs', js: true do
  login_admin

  context 'show expert reminder by duration' do
    let(:region) { create :territory, :region, deployed_at: 1.year.ago }
    let(:commune) { create :commune, regions: [region] }
    let!(:need1) { create :need, created_at: 10.days.ago, facility: create(:facility, commune: commune) }
    let!(:need1_match) { create :match, need: need1, created_at: 10.days.ago }
    let!(:need2) { create :need, created_at: 10.days.ago }
    let!(:need2_match) { create :match, need: need2, created_at: 10.days.ago }

    it 'displays experts' do
      visit poke_reminders_needs_path
      expect(page.html).to include 'Relances'
      click_link(href: "/relances/besoins/sans-reponse")
      expect(page).to have_content(need2.company.name)
      expect(page).to have_css('.card', count: 2)
      select(region.name, from: 'by_region')
      # Trying to get rid of flaky test
      page.find_button('Rechercher').execute_script('this.click()')
      page.find_by_id('clear-search')
      expect(page).to have_no_content(need2.company.name)
      expect(page).to have_css('.card', count: 1)
    end
  end
end
