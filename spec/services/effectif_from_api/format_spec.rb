# frozen_string_literal: true

require 'rails_helper'
describe EffectifFromApi::Format do
  describe 'code_effectif' do
    subject { described_class.new(effectifs, tranche_effectif).code_effectif }

    context 'with missing params' do
      let(:effectifs) { nil }
      let!(:tranche_effectif) { nil }

      it{ is_expected.to be_nil }
    end

    context 'with missing effectifs' do
      let(:effectifs) { nil }
      let!(:tranche_effectif) { { "de" => 100, "a" => 199, "code" => "22", "date_reference" => "2018", "intitule" => "100 à 199 salariés" } }

      it{ is_expected.to eq '22' }
    end

    context 'with missing effectif range' do
      let!(:effectifs) { { "siret" => "41816609600069", "annee" => "2020", "mois" => "08", "effectifs_mensuels" => "412.60" } }
      let(:tranche_effectif) { nil }

      it{ is_expected.to eq '32' }
    end

    context 'with newer effectifs' do
      let!(:effectifs) { { "siret" => "41816609600069", "annee" => "2020", "mois" => "08", "effectifs_mensuels" => "412.60" } }
      let!(:tranche_effectif) { { "de" => 100, "a" => 199, "code" => "22", "date_reference" => "2018", "intitule" => "100 à 199 salariés" } }

      it{ is_expected.to eq '32' }
    end

    context 'with newer effectifs range' do
      let!(:effectifs) { { "siret" => "41816609600069", "annee" => "2020", "mois" => "08", "effectifs_mensuels" => "412.60" } }
      let!(:tranche_effectif) { { "de" => 100, "a" => 199, "code" => "22", "date_reference" => "2021", "intitule" => "100 à 199 salariés" } }

      it{ is_expected.to eq '22' }
    end
  end
end
