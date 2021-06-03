# frozen_string_literal: true

require 'rails_helper'
describe SolicitationModification::Update do
  describe 'call' do
    let(:solicitation) { create :solicitation, created_at: 2.weeks.ago }
    let(:service) { described_class.call(solicitation, params) }

    context 'with deployed code region' do
      let(:params) { { code_region: "11" } }

      it "updates sollicitation" do
        expect(service.code_region).to eq(11)
      end

      it "turns created_in_deployed_region to true" do
        expect(service.created_in_deployed_region).to be(true)
      end
    end

    context 'with undeployed code region' do
      let(:params) { { code_region: "666" } }

      it "doesnt turn created_in_deployed_region to true" do
        expect(service.created_in_deployed_region).not_to be(true)
      end
    end

    context 'with no code region' do
      let(:params) { { code_region: nil } }

      it "doesnt turn created_in_deployed_region to true" do
        expect(service.created_in_deployed_region).not_to be(true)
      end
    end

    context 'in lately deployed region' do
      let(:newly_deployed_region) { create :territory, :region, code_region: 22, deployed_at: Time.zone.now }
      let(:params) { { code_region: 22 } }

      it "doesnt turn created_in_deployed_region to true" do
        expect(service.created_in_deployed_region).not_to be(true)
      end
    end
  end
end
