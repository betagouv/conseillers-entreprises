# frozen_string_literal: true

require 'rails_helper'

describe 'Manager::StatsController features' do
  login_manager

  describe 'index' do
    it do
      current_user.user_rights.create(category: 'admin')
      visit '/manager/stats'
      expect(page.html).to include 'Statistiques'
    end
  end

  describe 'load_data' do
    it do
      visit 'manager/load_data?chart_name=needs_transmitted'
      expect(page.html).to include 'Besoins transmis'
    end
  end
end
