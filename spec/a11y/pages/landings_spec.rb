# frozen_string_literal: true

require 'rails_helper'

describe 'landings', type: :feature, js: true do
  let!(:landing) { create :landing, title: 'Accueil', slug: 'accueil' }
  let(:landing_theme) { create :landing_theme, title: 'Theme', slug: 'theme' }

  subject { page }

  describe '/' do
    before { visit '/' }

    it do
      is_expected.to be_accessible
      is_expected.to have_skiplinks_ids
    end
  end

  describe '/aide-entreprise/:landing_slug' do
    before { visit "/aide-entreprise/#{Landing.last.slug}" }

    it do
      is_expected.to be_accessible
      is_expected.to have_skiplinks_ids
    end
  end

  describe '/aide-entreprise/:landing_slug/theme/:slug' do
    before { visit "/aide-entreprise/#{landing.slug}/theme/#{landing_theme.slug}" }

    it do
      is_expected.to be_accessible
      is_expected.to have_skiplinks_ids
    end
  end
end
