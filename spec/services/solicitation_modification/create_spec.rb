# frozen_string_literal: true

require 'rails_helper'
describe SolicitationModification::Create do
  describe 'call' do
    let(:landing) { create :landing, slug: 'accueil', title: 'Test Landing' }
    let!(:landing_subject) { create :landing_subject, requires_siret: true }

    let(:base_params) {
      {
        landing_subject_id: landing_subject.id,
        landing_id: landing.id,
        full_name: "Leslie Crane",
        phone_number: "+974-65-7100124",
        email: "rotoce@gmail.com",
        siret: "89264276000011",
        description: "Ma demande"
      }
    }
    let(:service) { described_class.call(params) }

    context 'with deployed code region' do
      let(:params) { base_params.merge(code_region: "11") }

      it "creates sollicitation" do
        expect(service).to be_persisted
      end

      it "turns created_in_deployed_region to true" do
        expect(service.created_in_deployed_region).to be(true)
      end
    end

    context 'with undeployed code region' do
      let(:params) { base_params.merge(code_region: "666") }

      it "creates sollicitation" do
        expect(service).to be_persisted
      end

      it "doesnt turn created_in_deployed_region to true" do
        expect(service.created_in_deployed_region).not_to be(true)
      end
    end

    context 'with no code region' do
      let(:params) { base_params.merge(code_region: nil) }

      it "creates sollicitation" do
        expect(service).to be_persisted
      end

      it "doesnt turn created_in_deployed_region to true" do
        expect(service.created_in_deployed_region).not_to be(true)
      end
    end
  end
end
