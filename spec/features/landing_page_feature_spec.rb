# frozen_string_literal: true

require 'rails_helper'

describe 'Landing Page Feature', type: :feature do
  before do
    Rails.cache.clear
    create :landing, :featured, slug: 'landing', button: 'Go to Home'
  end

  describe 'get solicitation with pk params' do
    before do
      visit '/aide/landing?pk_campaign=foo&pk_kwd=bar'
      click_link 'Go to Home'
    end

    it { expect(page).to have_current_path '/aide/landing?pk_campaign=foo&pk_kwd=bar' }
  end
end
