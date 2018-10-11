# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocalOffice, type: :model do
  it do
    is_expected.to have_many :experts
    is_expected.to validate_presence_of :name
  end

  describe 'scopes' do
    describe 'of_naf_code' do
      subject { LocalOffice.of_naf_code naf_code }

      let(:commerce_naf_code) { '6202A' }
      let(:artisanry_naf_code) { '1011Z' }

      let!(:commerce_local_office) { create :local_office, qualified_for_artisanry: false, qualified_for_commerce: true }
      let!(:artisanry_local_office) { create :local_office, qualified_for_artisanry: true, qualified_for_commerce: false }
      let!(:all_business_local_office) do
        create :local_office, qualified_for_artisanry: true, qualified_for_commerce: true
      end

      context 'artisanry' do
        let(:naf_code) { artisanry_naf_code }

        it { is_expected.to match_array [artisanry_local_office, all_business_local_office] }
      end

      context 'commerce' do
        let(:naf_code) { commerce_naf_code }

        it { is_expected.to match_array [commerce_local_office, all_business_local_office] }
      end
    end
  end

  describe 'to_s' do
    it do
      local_office = create :local_office, name: 'Direccte'
      expect(local_office.to_s).to eq 'Direccte'
    end
  end
end
