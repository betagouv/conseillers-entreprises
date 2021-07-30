# frozen_string_literal: true

require 'rails_helper'

describe 'a11y', type: :feature, js: true do
  subject { page }

  before do
    create :landing, :with_subjects, slug: 'home'
    create :landing, :with_subjects, slug: 'landing-two',
      title: 'Titre landing'
  end

  describe '/' do
    before { visit '/' }

    it { is_expected.to be_accessible }
  end

  describe '/aide-entreprises/:slug' do
    before { visit "/aide-entreprises/#{Landing.last.slug}" }

    it { is_expected.to be_accessible }
  end

  describe '/aide-entreprises/:landing_slug/theme/:slug' do
    before do
      landing = Landing.last
      visit "/aide-entreprises/#{landing.slug}/theme/#{landing.landing_themes.first.slug}"
    end

    it { is_expected.to be_accessible }
  end

  describe '/aide-entreprises/:landing_slug/demande/:slug' do
    before do
      landing = Landing.last
      visit "/aide-entreprises/#{landing.slug}/demande/#{landing.landing_subjects.first.slug}"
    end

    it { is_expected.to be_accessible }
  end
end
