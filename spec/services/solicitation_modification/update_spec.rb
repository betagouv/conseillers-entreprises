# frozen_string_literal: true

require 'rails_helper'
describe SolicitationModification::Update do
  describe 'call!' do
    let(:service) { described_class.new(solicitation, params).call! }

    context 'code_region update' do
      let(:solicitation) { create :solicitation, created_at: 2.weeks.ago, code_region: nil, siret: 'wrong siret' }

      context 'with deployed code region' do
        let(:params) { { code_region: "11" } }

        it "updates solicitation" do
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

    context 'step_company update' do
      let!(:solicitation) { create :solicitation, full_name: 'Louise Michel', email: 'louise@michel.org', phone_number: 'xx', status: 'step_company', siret: nil }

      context 'with blank siret' do
        let(:params) { { siret: "  " } }

        it "invalidates solicitation" do
          expect(service.valid?).to be(false)
        end

        it 'doesnt change status' do
          expect(service.reload.status).to eq('step_company')
        end
      end

      context 'with incorrect siret' do
        let(:params) { { siret: "123 456 789 00011" } }

        it "invalidates solicitation" do
          expect(service.valid?).to be(false)
        end

        it 'doesnt change status' do
          expect(service.reload.status).to eq('step_company')
        end
      end

      context 'with correct siret' do
        let(:params) { { siret: "41816609600069" } }

        it "invalidates solicitation" do
          expect(service.valid?).to be(true)
          expect(service.reload.siret).to eq("41816609600069")
        end

        it 'doesnt change status' do
          expect(service.reload.status).to eq('step_description')
        end
      end
    end
  end

  describe 'call' do
    let(:solicitation) { create :solicitation, created_at: 2.weeks.ago, code_region: nil, siret: 'wrong siret' }
    let(:service) { described_class.new(solicitation, params).call }

    context 'with deployed code region' do
      let(:params) { { code_region: "11" } }

      it "updates sollicitation" do
        expect(service.code_region).to eq(11)
      end

      it "turns created_in_deployed_region to true" do
        expect(service.created_in_deployed_region).to be(true)
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
