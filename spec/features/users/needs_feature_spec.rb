# frozen_string_literal: true

require 'rails_helper'

describe 'experts', type: :feature do
  describe 'expert update' do
    let(:expert) { create :expert, users: [current_user] }
    let!(:match) { create :match, expert: expert }
    let(:need_subject) { match.need.subject.label }

    login_user

    it 'shows the need to user' do
      visit needs_path
      expect(page.html).to include 'Demandes reçues'
      expect(page.html).to include need_subject
      page.click_link('', :href => "/analyses/#{match.need.diagnosis.id}")
    end
  end
end
