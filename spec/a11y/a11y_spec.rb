# frozen_string_literal: true

require 'rails_helper'

describe 'a11y', type: :feature, js: true do
  subject { page }

  before do
    create :landing, :with_subjects, slug: 'accueil'
    create :landing, :with_subjects, slug: 'landing-two',
      title: 'Titre landing'
  end

  describe '/' do
    before { visit '/' }

    it { is_expected.to be_accessible }
  end

  describe '/aide-entreprise/:landing_slug' do
    before { visit "/aide-entreprise/#{Landing.last.slug}" }

    it { is_expected.to be_accessible }
  end

  describe '/aide-entreprise/:landing_slug/theme/:slug' do
    before do
      landing = Landing.last
      visit "/aide-entreprise/#{landing.slug}/theme/#{landing.landing_themes.first.slug}"
    end

    it { is_expected.to be_accessible }
  end

  describe '/aide-entreprise/:landing_slug/demande/:slug' do
    before do
      landing = Landing.last
      visit "/votre-demande/nouvelle-demande?landing_id=#{landing.id}&landing_subject_id=#{landing.landing_subjects.first.id}"
    end

    it { is_expected.to be_accessible }
  end
end
