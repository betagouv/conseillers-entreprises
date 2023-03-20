# frozen_string_literal: true

require 'rails_helper'

describe 'reminders experts', js: true do
  login_admin

  context 'show expert reminder by duration' do
    create_experts_for_reminders

    before { RemindersService.create_reminders_registers }

    it 'displays experts' do
      visit reminders_path
      expect(page.html).to include 'Relances'
      expect(page.html).to include 'Par expert'
      page.click_link(href: "/relances/experts/superieur-a-cinq-besoins")
      expect(page).to have_css('.card', count: 1)
      expect(page).to be_accessible
      page.click_link(href: "/relances/experts/entre-deux-et-cinq-besoins")
      expect(page).to have_css('.card', count: 1)
      expect(page).to be_accessible
      page.click_link(href: "/relances/experts/un-besoin-recent")
      expect(page).to have_css('.card', count: 2)
      expect(page).to be_accessible
    end
  end

  context 'show expert reminder input and output' do
    create_registers_for_reminders

    before { RemindersService.create_reminders_registers }

    context 'reminders_path' do
      it 'displays page' do
        visit reminders_path
        expect(page.html).to include 'Relances'
        expect(page.html).to include 'Par expert'
      end
    end

    context 'inputs_reminders_experts_path' do
      it 'displays page' do
        visit inputs_reminders_experts_path
        expect(page).to have_css('.card', count: 2)
        expect(page).to be_accessible
      end
    end

    context 'outputs_reminders_experts' do
      it 'displays page' do
        visit outputs_reminders_experts_path
        expect(page).to have_css('.card', count: 3)
        expect(page).to be_accessible
      end
    end
  end
end
