# frozen_string_literal: true

require 'rails_helper'

describe 'Landing Page Feature', type: :feature do
  before do
    create :landing, slug: 'landing', button: 'Go to Home'
  end

  describe 'get solicitation with pk params' do
    before do
      visit '/aide/landing?pk_campaign=foo&pk_kwd=bar'
      click_link 'Go to Home'
    end

    it { expect(page).to have_current_path '/?pk_campaign=foo&pk_kwd=bar&slug=landing' }
  end
end
