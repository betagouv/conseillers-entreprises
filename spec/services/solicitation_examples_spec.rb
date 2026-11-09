require 'rails_helper'

describe SolicitationExamples do
  subject(:examples) { described_class.new(landing_subject) }

  let(:landing_subject) { build :landing_subject, slug: 'reduction-impots' }

  describe '#any?' do
    context 'when the landing subject has published examples' do
      it { is_expected.to be_any }
    end

    context 'when the landing subject has no examples' do
      let(:landing_subject) { build :landing_subject, slug: 'sujet-sans-exemple' }

      it { is_expected.not_to be_any }
    end
  end

  describe '#cases' do
    context 'when the landing subject has no examples' do
      let(:landing_subject) { build :landing_subject, slug: 'sujet-sans-exemple' }

      it { expect(examples.cases).to eq [] }
    end
  end

  describe '#description' do
    before { allow(landing_subject).to receive(:solicitable_institutions_names).and_return(institutions) }

    context 'with partner institutions' do
      let(:institutions) { ['Banque de France', 'DGFiP', 'Urssaf'] }

      it 'names them in a sentence' do
        expect(examples.description).to include('Banque de France, DGFiP et Urssaf')
      end
    end

    context 'with a single partner institution' do
      let(:institutions) { ['DGFiP'] }

      it 'uses the singular' do
        expect(examples.description).to include('au sein de l’organisme suivant : DGFiP.')
      end
    end

    context 'without partner institutions' do
      let(:institutions) { [] }

      it 'stays readable without any partner mention' do
        expect(examples.description).to include('près de chez eux. Ces conseillers')
      end
    end
  end

  describe 'published content' do
    it 'covers every subject of the GEO test' do
      expect(described_class.data.keys).to contain_exactly(
        :'reduction-impots', :'reprendre-entreprise', :tresorerie,
        :eau, :'bilan-rse', :'transport-mobilite', :'demarche-ecologie', :energie, :dechets
      )
    end

    described_class.data.each do |slug, content|
      context "for #{slug}" do
        it 'gives each case a title and a text' do
          expect(content[:cases]).to all(include(title: be_present, text: be_present))
        end

        it 'does not expose direct identifiers' do
          texts = content[:cases].pluck(:text)

          expect(texts).not_to include(match(/\S+@\S+\.\S+/)) # Do not expose email addresses
          expect(texts).not_to include(match(/(?:\+33|\b0)[\s.]?[1-9](?:[\s.]?\d{2}){4}\b/)) # Do not expose phone numbers
          expect(texts).not_to include(match(/\b\d{3}\s?\d{3}\s?\d{3}(?:\s?\d{5})?\b/)) # Do not expose SIREN or SIRET numbers
        end
      end
    end
  end
end
