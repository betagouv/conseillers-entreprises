# frozen_string_literal: true

require 'rails_helper'
describe QueryFromEntreprendre do
  describe 'call' do
  subject { described_class.new(campaign: campaign, kwd: kwd).call }

    context 'with nil values' do
      let(:campaign) { nil }
      let(:kwd) { nil }

      it{ is_expected.to be(false) }
    end

    context 'with entreprendre campaign' do
      let(:campaign) { 'entreprendre' }
      let(:kwd) { nil }

      it{ is_expected.to be(true) }
    end

    context 'with not entreprendre campaign' do
      let(:campaign) { 'fructifier' }
      let(:kwd) { nil }

      it{ is_expected.to be(false) }
    end

    context 'with entreprendre kwd' do
      let(:campaign) { nil }
      let(:kwd) { 'F1234' }

      it{ is_expected.to be(true) }
    end

    context 'with not entreprendre kwd' do
      let(:campaign) { nil }
      let(:kwd) { '123-bois' }

      it{ is_expected.to be(false) }
    end
  end
end
