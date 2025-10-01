require 'rails_helper'

RSpec.describe LandingSubject do
  describe 'autoclean_textareas' do
    let!(:landing_subject) do
      create :landing_subject,
             description: '<p>Description</p>',
             description_explanation: "<ul><li>votre activité </li><li>le statut de l'entreprise</li></ul><p><br></p>",
             description_prefill: "Bonjour,\r\n\r\nMon entreprise a une activité de \r\n\r\nMerci d'avance pour votre appel",
             form_description: "<p><br></p><p>Quelque chose.</p><p><br></p>"
    end

    it do
      expect(landing_subject.description).to eq('<p>Description</p>')
      expect(landing_subject.description_explanation).to eq("<ul><li>votre activité </li><li>le statut de l'entreprise</li></ul>")
      expect(landing_subject.description_prefill).to eq("Bonjour,\r\n\r\nMon entreprise a une activité de \r\n\r\nMerci d'avance pour votre appel")
      expect(landing_subject.form_description).to eq('<p>Quelque chose.</p>')
    end
  end

  describe 'slug uniqueness' do
    subject { build :landing_subject, slug: slug, landing_theme: landing_theme }

    let(:landing_1) { create :landing }
    let(:landing_theme_1) { create :landing_theme }
    let!(:landing_subject_1) { create :landing_subject, slug: 'tata-yoyo', landing_theme: landing_theme_1 }

    before { landing_1.landing_themes << landing_theme_1 }

    context 'taken slug in other landing & landing_theme' do
      let(:landing_theme) { create(:landing_theme) }
      let(:landing) { create(:landing) }
      let(:slug) { 'tata-yoyo' }

      before { landing.landing_themes << landing_theme }

      it { is_expected.to be_valid }
    end

    context 'taken slug in same landing' do
      let(:landing_theme) { create(:landing_theme) }
      let(:landing) { landing_1 }
      let(:slug) { 'tata-yoyo' }

      before { landing_1.landing_themes << landing_theme }

      it { is_expected.not_to be_valid }
    end

    context 'taken slug in same landing_theme' do
      let(:landing_theme) { landing_theme_1 }
      let(:landing) { create(:landing) }
      let(:slug) { 'tata-yoyo' }

      before { landing.landing_themes << landing_theme }

      it { is_expected.not_to be_valid }
    end

    context 'other slug in same landing' do
      let(:landing_theme) { landing_theme_1 }
      let(:landing) { landing_1 }
      let(:slug) { 'grand-chapeau' }

      it { is_expected.to be_valid }
    end
  end
end
