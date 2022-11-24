# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CategorieJuridique do
  describe 'description' do
    subject { described_class.description(legal_form_code, niveau) }

    let(:niveau) { 1 }
    let(:legal_form_code) { '6316' }

    context 'nil code' do
      let(:legal_form_code) { nil }

      it { is_expected.to eq 'Autre' }
    end

    context 'empty code' do
      let(:legal_form_code) { '' }

      it { is_expected.to eq 'Autre' }
    end

    context 'unknown code' do
      let(:legal_form_code) { '0000' }

      it { is_expected.to eq 'Autre' }
    end

    context 'niveau 1' do
      let(:niveau) { 1 }

      it { is_expected.to eq 'Autre personne morale immatriculée au RCS' }
    end

    context 'niveau 2' do
      let(:niveau) { 2 }

      it { is_expected.to eq 'Société coopérative agricole' }
    end

    context 'niveau 3' do
      let(:niveau) { 3 }

      it { is_expected.to eq 'Coopérative d\'utilisation de matériel agricole en commun (CUMA)' }
    end
  end
end
