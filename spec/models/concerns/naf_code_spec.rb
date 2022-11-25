require 'rails_helper'

RSpec.describe NafCode do
  describe 'naf_libelle' do
    subject { described_class.naf_libelle(naf_code, level) }

    context 'valid code no level' do
      subject { described_class.naf_libelle(naf_code) }

      let(:naf_code) { 'GI' }

      it{ is_expected.to eq 'Commerce de gros et de détail, transports, hébergement et restauration' }
    end

    context 'valid code with level' do
      let(:naf_code) { '16' }
      let(:level) { 'level2' }

      it{ is_expected.to eq 'Travail du bois et fabrication d’articles en bois et en liège, à l’exception des meubles ; fabrication d’articles en vannerie et sparterie' }
    end

    context 'nil code' do
      let(:naf_code) { nil }
      let(:level) { nil }

      it{ is_expected.to eq 'Données manquantes' }
    end
  end

  describe 'code_a10' do
    subject { described_class.code_a10 naf_code }

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
