# frozen_string_literal: true

require 'rails_helper'
describe Effectif::Format do
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

      let!(:effectifs) { { "regime" => "regime_general", "nature" => "effectif_moyen_annuel", "value" => "412.60", "date_derniere_mise_a_jour" => "2023-03-30", "annee" => "2020" } }
      let(:tranche_effectif) { nil }

      it{ is_expected.to eq '32' }
    end

    context 'with newer effectifs' do
      let!(:effectifs) { { "regime" => "regime_general", "nature" => "effectif_moyen_annuel", "value" => "412.60", "date_derniere_mise_a_jour" => "2023-03-30", "annee" => "2020" } }
      let!(:tranche_effectif) { { "de" => 100, "a" => 199, "code" => "22", "date_reference" => "2018", "intitule" => "100 à 199 salariés" } }

      it{ is_expected.to eq '32' }
    end

    context 'with newer effectifs range' do
      let!(:effectifs) { { "regime" => "regime_general", "nature" => "effectif_moyen_annuel", "value" => "412.60", "date_derniere_mise_a_jour" => "2023-03-30", "annee" => "2020" } }
      let!(:tranche_effectif) { { "de" => 100, "a" => 199, "code" => "22", "date_reference" => "2021", "intitule" => "100 à 199 salariés" } }

      it{ is_expected.to eq '22' }
    end
  end
end
