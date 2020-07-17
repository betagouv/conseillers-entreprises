# frozen_string_literal: true

require 'rails_helper'

describe 'a11y', type: :feature, js: true do
  subject { page }

  before do
    create :landing, home_sort_order: 0,
           home_title: 'Premier Test',
           home_description: 'Ceci est un test.',
           title: 'Premier titre',
           subtitle: 'Premier sous-titre'

    create :landing, home_sort_order: 1,
           home_title: 'Second test',
           home_description: 'Encore un test.',
           title: 'Second titre',
           subtitle: 'Second sous-titre'
  end

  describe '/' do
    before { visit '/' }

    it { is_expected.to be_accessible }
  end

  describe '/aide-entreprises/:slug' do
    before { visit "/aide-entreprises/#{Landing.last.slug}" }

    it { is_expected.to be_accessible }
  end

  describe '/aide-entreprises/:slug/demande' do
    before { visit "/aide-entreprises/#{Landing.last.slug}/demande" }

    it { is_expected.to be_accessible }
  end
end
