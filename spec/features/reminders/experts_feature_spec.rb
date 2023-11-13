# frozen_string_literal: true

require 'rails_helper'

describe 'reminders experts', :js do
  login_admin

  context 'show expert reminder by duration' do
    create_experts_for_reminders

    before { RemindersService.new.create_reminders_registers }

    xit 'displays experts and opens expert BAL' do
      visit inputs_reminders_experts_path
      expect(page.html).to include 'Paniers qualité'
      p "many_pending_needs expected count : 1"
      page.click_link(href: "/relances/experts/superieur-a-cinq-besoins")
      p "many_pending_needs real count : #{Expert.many_pending_needs.distinct.size}"
      expect(page).to have_css('.card', count: 1, wait: 10)
      expect(page).to be_accessible
      p "medium_pending_needs expected count : 1 "
      page.click_link(href: "/relances/experts/entre-deux-et-cinq-besoins")
      p "medium_pending_needs real count : #{Expert.medium_pending_needs.distinct.size}"
      expect(page).to have_css('.card', count: 1, wait: 10)
      expect(page).to be_accessible
      p "one_pending_need expected count : 2"
      page.click_link(href: "/relances/experts/un-besoin-recent")
      p "one_pending_need real count : #{Expert.one_pending_need.distinct.size}"
      expect(page).to have_css('.card', count: 2, wait: 10)
      expect(page).to be_accessible
      click_link("1 boite de réception", match: :first)
      expect(page).to have_text("Boite de réception")
    end
  end

  context 'show expert reminder input and output' do
    create_registers_for_reminders

    before { RemindersService.new.create_reminders_registers }

    context 'reminders_path' do
      it 'displays page' do
        visit inputs_reminders_experts_path
        expect(page.html).to include 'Relances'
        expect(page.html).to include 'Paniers qualité'
      end
    end

    context 'inputs_reminders_experts_path' do
      it 'displays page' do
        visit inputs_reminders_experts_path
        expect(page).to have_css('.card', count: 2, wait: 10)
        expect(page).to be_accessible
      end
    end

    context 'outputs_reminders_experts' do
      it 'displays page' do
        visit outputs_reminders_experts_path
        expect(page).to have_css('.card', count: 3, wait: 10)
        expect(page).to be_accessible
      end
    end
  end
end
