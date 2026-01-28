require 'rails_helper'

RSpec.describe Api::Internal::CommunesSearch do
  subject(:results) { described_class.new(query).call }

  before do
    Rails.cache.clear
  end

  describe '#call' do
    context 'with a valid query' do
      let(:query) { 'Paris' }

      it { is_expected.to be_an(Array) }

      it 'returns communes matching the query' do
        expect(results).to include(hash_including(nom: match(/Paris/i)))
      end

      it 'returns communes with the expected structure' do
        expect(results).to all(include(:nom, :code, :departement_code, :departement_nom, :normalized_nom))
      end
    end

    context 'with accented characters' do
      let(:query) { 'Étretat' }

      it 'finds the commune' do
        expect(results).to include(hash_including(nom: 'Étretat'))
      end

      it 'returns the same results as a search without accents' do
        expect(results).to eq(described_class.new('Etretat').call)
      end
    end

    context 'with case insensitive search' do
      let(:query) { 'MARSEILLE' }

      it 'returns the same results regardless of case' do
        expect(results).to eq(described_class.new('marseille').call)
      end
    end

    context 'with many matching results' do
      let(:query) { 'Saint' }

      it 'limits results to 20' do
        expect(results.length).to eq(20)
      end
    end

    context 'with empty string query' do
      let(:query) { '' }

      it { is_expected.to eq([]) }
    end

    context 'with whitespace only query' do
      let(:query) { '   ' }

      it { is_expected.to eq([]) }
    end

    context 'with nil query' do
      let(:query) { nil }

      it { is_expected.to eq([]) }
    end

    context 'with non-existent commune' do
      let(:query) { 'XYZNONEXISTENT999' }

      it { is_expected.to eq([]) }
    end

    context 'with hyphenated query' do
      let(:query) { 'Saint-Denis' }

      it 'finds matching communes' do
        expect(results).to include(hash_including(nom: match(/Saint-Denis/i)))
      end
    end

    context 'with partial match' do
      let(:query) { 'bourg' }

      it 'matches substring in commune name' do
        expect(results).not_to be_empty
        expect(results).to all(include(normalized_nom: match(/bourg/)))
      end
    end

    context 'with departement information' do
      let(:query) { 'Paris' }

      it 'includes correct departement data' do
        paris = results.find { |c| c[:nom] == 'Paris' }
        expect(paris).to include(departement_code: '75', departement_nom: 'Paris')
      end
    end
  end
end
