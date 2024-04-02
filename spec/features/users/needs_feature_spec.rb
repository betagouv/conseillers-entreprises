# frozen_string_literal: true

require 'rails_helper'

describe 'needs' do
  describe 'need display' do
    let(:expert) { create :expert, users: [current_user] }
    let!(:match) { create :match, expert: expert }
    let(:need_subject) { match.need.subject.label }

    login_user

    it 'shows the need to user' do
      visit needs_path
      expect(page.html).to include 'Besoins reçus'
      expect(page.html).to include match.diagnosis.company.name
      page.click_on(need_subject)
      expect(page.html).to include need_subject
    end
  end
end
