# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiConsumption::Models::Facility::ApiEntreprise do
  describe 'new' do
    let!(:api_model) { described_class.new(params) }

    context 'without params' do
      let(:params) { nil }

      it 'fails silently' do
        expect{ api_model }.not_to raise_error
      end
    end
  end

  describe 'etablissement principal' do
    context 'no data' do
      let!(:params) do
        {
          siret: "41816609600069",
          forme_exercice: nil,
          activites_secondaires:
            { etablissement_principal:
              {
                siret: "41816609600069",
                activites:
                  [
                    { formeExercice: nil, codeApe: "7112B", codeAprm: nil }
                  ]
              },
              autres_etablissements: [
                {
                  siret: "41816609600072",
                activites:
                  [
                    { formeExercice: "GESTION_DE_BIENS", codeApe: "6820A", codeAprm: nil }
                  ]
                },
              ]
            }
        }
      end

      it 'returns empty nature activites' do
        expect(described_class.new(params).nature_activites).to be_empty
      end

      it 'returns correct nafa' do
        expect(described_class.new(params).nafa_codes).to be_empty
      end
    end

    context 'double nature' do
      let!(:params) do
        {
          siret: "41816609600069",
          forme_exercice: "INDEPENDANTE",
          activites_secondaires:
            { etablissement_principal:
              {
                siret: "41816609600069",
                activites:
                  [
                    { formeExercice: "INDEPENDANTE", codeApe: "7112B", codeAprm: nil },
                    { formeExercice: "ARTISANALE_REGLEMENTEE", codeApe: nil, codeAprm: "43.22B-A" },
                    { formeExercice: "ARTISANALE_REGLEMENTEE", codeApe: nil, codeAprm: "43.22A-Z" }
                  ]
              },
              autres_etablissements: []
            }
        }
      end

      it 'returns correct nature activites' do
        expect(described_class.new(params).nature_activites).to contain_exactly("INDEPENDANTE", "ARTISANALE_REGLEMENTEE")
      end

      it 'returns correct nafa' do
        expect(described_class.new(params).nafa_codes).to contain_exactly("43.22B-A", "43.22A-Z")
      end
    end
  end

  describe 'autre etablissement' do
    context 'simple nature' do
      let!(:params) do
        {
          siret: "41816609600072",
          forme_exercice: nil,
          activites_secondaires:
            { etablissement_principal:
              {
                siret: "41816609600069",
                activites:
                  [
                    { formeExercice: "GESTION_DE_BIENS", codeApe: "7112B", codeAprm: nil }
                  ]
              },
              autres_etablissements: [
                {
                  siret: "41816609600072",
                activites:
                  [
                    { formeExercice: "LIBERALE_REGLEMENTEE", codeApe: "6820A", codeAprm: nil }
                  ]
                },
              ]
            }
        }
      end

      it 'returns correct nature activites' do
        expect(described_class.new(params).nature_activites).to contain_exactly("LIBERALE_REGLEMENTEE")
      end
    end
  end
end