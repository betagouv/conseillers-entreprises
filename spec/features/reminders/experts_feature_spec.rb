# frozen_string_literal: true

require 'rails_helper'

describe 'reminders experts', type: :feature do
  describe 'show expert reminder' do
    let!(:expert_critical_rate_01) { create :expert }
    let!(:expert_critical_rate_02) { create :expert }
    let!(:expert_worrying_rate_01) { create :expert }
    let!(:expert_worrying_rate_02) { create :expert }
    let!(:expert_pending_rate) { create :expert }
    let!(:expert_no_rate) { create :expert }

    before do
      expert_critical_rate_01.received_matches << [
        create(:match, created_at: 8.days.ago)
      ]
      expert_critical_rate_02.received_matches << [
        create(:match, created_at: 8.days.ago),
        create(:match, created_at: 8.days.ago),
        create(:match, created_at: 10.days.ago),
        create(:match, created_at: 8.days.ago, status: 'taking_care')
      ]
      expert_worrying_rate_01.received_matches << [
        create(:match, created_at: 8.days.ago),
        create(:match, created_at: 8.days.ago, status: 'taking_care')
      ]
      expert_worrying_rate_02.received_matches << [
        create(:match, created_at: 8.days.ago),
        create(:match, created_at: 61.days.ago),
        create(:match, created_at: 61.days.ago),
        create(:match, created_at: 8.days.ago, status: 'taking_care')
      ]
      expert_pending_rate.received_matches << [
        create(:match, created_at: 8.days.ago),
        create(:match, created_at: 8.days.ago, status: 'taking_care'),
        create(:match, created_at: 8.days.ago, status: 'taking_care')
      ]
    end

    login_admin

    it 'works' do
      visit reminders_path
      expect(page.html).to include 'Relances'
      expect(page.html).to include 'Par taux de positionnement d’expert'
      page.click_link(href: "/relances/experts/taux-positionnement-restant")
      expect(page).to have_css('.fr-card', count: 1)
      page.click_link(href: "/relances/experts/taux-positionnement-critique")
      expect(page).to have_css('.fr-card', count: 2)
      page.click_link(href: "/relances/experts/taux-positionnement-a-surveiller")
      expect(page).to have_css('.fr-card', count: 2)
      page.click_link(href: "/relances/experts/#{expert_worrying_rate_02.id}/prises_en_charge")
      expect(page.html).to include expert_worrying_rate_02.full_name
    end
  end
end
