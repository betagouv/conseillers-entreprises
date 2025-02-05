# frozen_string_literal: true

require 'rails_helper'
describe GetProvenanceDetails do
  describe 'call' do
    let(:cooperation) { create(:cooperation) }

    subject { described_class.new(cooperation, query).call }

    context 'with no provenance details' do
      let(:query) { 'F12' }

      it{ is_expected.to match_array([]) }
    end

    context 'with corresponding provenance details' do
      let(:query) { 'F12' }
      let!(:solicitation) { create(:solicitation, cooperation: cooperation, provenance_detail: 'F1234') }

      it{ is_expected.to contain_exactly('F1234') }
    end

    context 'with no corresponding provenance details' do
      let(:query) { 'F12' }
      let!(:solicitation) { create(:solicitation, cooperation: cooperation, provenance_detail: 'aide-aux-entreprises') }

      it{ is_expected.to match_array([]) }
    end
  end
end
