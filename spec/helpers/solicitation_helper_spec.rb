# frozen_string_literal: true

require 'rails_helper'

describe SolicitationHelper do
  describe 'display_region' do
    context 'without region filter' do
      let(:region) { create :territory, :region }

      subject { helper.display_region(region, nil) }

      it 'return region' do
        is_expected.to eq "<li class=\"item\">#{CGI.unescapeHTML(I18n.t('helpers.solicitation.localisation_html', region: region.name))}</li>"
      end
    end

    context 'with region filter' do
      let(:region) { create :territory, :region }

      subject { helper.display_region(region, 'Region Bretagne') }

      it 'return nothing' do
        is_expected.to be_nil
      end
    end

    context 'without region for solicitation' do
      let(:region) { nil }

      subject { helper.display_region(region, nil) }

      it 'return nothing' do
        is_expected.to be_nil
      end
    end
  end

  describe 'human_diagnosis_errors' do
    subject { helper.human_diagnosis_errors(errors) }

    context 'model error' do
      let(:errors) { { "matches" => [{ "error" => "preselected_institution_has_no_relevant_experts" }] } }

      it { is_expected.to eq ['Mises en relation : aucun expert de l’institution présélectionnée ne peut prendre en charge cette entreprise.'] }
    end

    context 'standard error' do
      let(:errors) { { "standard" => I18n.t('api_requests.invalid_siret_or_siren') } }

      it { is_expected.to eq ['L’identifiant (siret ou siren) est invalide'] }
    end

    context 'major error' do
      let(:errors) { { "major" => { "api-apientreprise-entreprise-base" => "Caramba !" } } }

      it { is_expected.to eq ['Api Entreprise (entreprise) : Caramba !'] }
    end
  end
end
