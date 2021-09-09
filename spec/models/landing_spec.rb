# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Landing, type: :model do
  describe 'validations' do
    it do
      is_expected.to have_many(:landing_themes)
      is_expected.to have_many(:solicitations)
    end
  end

  describe 'update_iframe_360' do
    let!(:home_landing) { create :landing, :with_subjects, slug: 'accueil' }
    let!(:contact_landing_theme) { create :landing_theme, slug: 'contactez-nous' }

    context 'with empty landing' do
      let(:landing) { create :landing }

      it do
        expect(landing.landing_themes.count).to eq(0)

        landing.update_iframe_360
        landing.reload
        expect(landing.landing_themes.count).to eq(3)
        expect(landing.landing_themes).to include(*home_landing.landing_themes)
        expect(landing.landing_themes).to include(contact_landing_theme)
      end
    end
  end
end
