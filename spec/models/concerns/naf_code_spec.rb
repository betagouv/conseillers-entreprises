require 'rails_helper'

RSpec.describe NafCode, type: :model do
  describe 'libelle_a10' do
    subject { described_class::libelle_a10 naf_code_a10 }

    context 'valid code' do
      let(:naf_code_a10) { 'GI' }

      it{ is_expected.to eq 'Commerce de gros et de détail, transports, hébergement et restauration' }
    end

    context 'nil code' do
      let(:naf_code_a10) { nil }

      it{ is_expected.to eq 'Données manquantes' }
    end
  end

  describe 'libelle_naf' do
    subject { described_class::libelle_naf('a10', naf_code_a10) }

    context 'valid code' do
      let(:naf_code_a10) { 'GI' }

      it{ is_expected.to eq 'Commerce de gros et de détail, transports, hébergement et restauration' }
    end

    context 'nil code' do
      let(:naf_code_a10) { nil }

      it{ is_expected.to eq 'Données manquantes' }
    end
  end

  describe 'code_a10' do
    subject { described_class::code_a10 naf_code }

    context 'valid code' do
      let(:naf_code) { '6202A' }

      it{ is_expected.to eq 'JZ' }
    end

    context 'nil code' do
      let(:naf_code) { nil }

      it{ is_expected.to be_nil }
    end
  end
end
