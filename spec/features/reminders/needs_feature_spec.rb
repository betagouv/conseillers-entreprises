# frozen_string_literal: true

require 'rails_helper'

describe 'reminders needs', js: true do
  login_admin

  context 'show expert reminder by duration' do
    let(:region) { create :territory, :region, name: "Région-01", code_region: 12345, deployed_at: 1.year.ago }
    let(:region2) { create :territory, :region, name: "Région-02", code_region: 6789, deployed_at: 1.year.ago }
    let(:commune) { create :commune, regions: [region] }
    let(:commune2) { create :commune, regions: [region2] }
    let!(:need1) { create :need, created_at: 10.days.ago, facility: create(:facility, commune: commune) }
    let!(:need1_match) { create :match, need: need1, created_at: 10.days.ago }
    let!(:need2) { create :need, created_at: 10.days.ago, facility: create(:facility, commune: commune2) }
    let!(:need2_match) { create :match, need: need2, created_at: 10.days.ago }

    xit 'displays experts' do
      visit poke_reminders_needs_path
      expect(page.html).to include 'Relances'
      click_link(href: "/relances/besoins/sans-reponse")
      expect(page).to have_content(need2.company.name)
      expect(page).to have_css('.card', count: 2)
      select(region.name, from: 'by_region')
      # Trying to get rid of flaky test
      p "expected count : 1"
      page.find_button('Rechercher').execute_script('this.click()')
      page.find_by_id('clear-search')
      p "real count : #{Need.by_region(region).distinct.size}"
      expect(page).not_to have_content(need2.company.name, wait: 10)
      expect(page).to have_css('.card', count: 1)
    end
  end
end
