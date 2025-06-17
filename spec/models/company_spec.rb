# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company do
  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to have_many :contacts }
  end

  describe 'to_s' do
    it do
      company = create :company, name: 'Octo'
      expect(company.to_s).to eq 'Octo'
    end
  end

  describe 'simple_effectif_eq' do
    subject { described_class.simple_effectif_eq(query) }

    let!(:company_1) { create :company, code_effectif: 51 }
    let!(:company_2) { create :company, code_effectif: 11 }
    let!(:company_3) { create :company, code_effectif: nil }
    let!(:company_4) { create :company, code_effectif: 32 }

    context 'nil query' do
      let(:query) { nil }

      it{ is_expected.to eq [] }
    end

    context 'invalid query' do
      let(:query) { '99' }

      it{ is_expected.to eq [] }
    end

    context 'valid query' do
      let(:query) { '250' }

      it{ is_expected.to contain_exactly(company_1, company_4) }
    end

  end
end
