# frozen_string_literal: true

require 'rails_helper'

describe 'reminders experts', type: :feature do
  describe 'show expert reminder' do
    let!(:expert_with_lots_inbox) { create :expert }
    let!(:expert_with_few_inbox) { create :expert }
    let!(:expert_with_few_taken_care) { create :expert }

    before do
      expert_with_lots_inbox.received_matches << [ create(:match, created_at: 8.days.ago), create(:match, created_at: 8.days.ago) ]
      expert_with_few_inbox.received_matches << [ create(:match, created_at: 8.days.ago), create(:match, created_at: 8.days.ago, status: 'taking_care'), create(:match, created_at: 8.days.ago, status: 'taking_care') ]
      expert_with_few_taken_care.received_matches << [ create(:match, created_at: 8.days.ago, status: 'taking_care') ]
    end

    login_admin

    it 'works' do
      visit reminders_path
      expect(page.html).to include 'Relances'
      expect(page.html).to include 'Experts'
      page.click_link('', href: "/relances/referents")
      expect(page).to have_css('.fr-card', count: 2)
      expect(page.html).not_to include expert_with_few_taken_care.full_name
      page.click_link('', href: "/relances/referents/#{expert_with_few_inbox.id}/prises_en_charge")
      expect(page.html).to include expert_with_few_inbox.full_name
    end
  end
end
