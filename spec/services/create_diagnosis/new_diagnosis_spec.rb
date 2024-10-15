# frozen_string_literal: true

require 'rails_helper'
describe CreateDiagnosis::NewDiagnosis do
  describe 'call' do
    subject(:diagnosis){ described_class.new(solicitation).call }

    context "with a solicitation" do
      let(:solicitation) { build :solicitation, full_name: 'my company' }

      it do
        expect(diagnosis.facility.company.name).to eq 'my company'
      end
    end

    context "without a solicitation" do
      let(:solicitation) { nil }

      it do
        expect(diagnosis.facility.company.name).to be_nil
      end
    end
  end
end
