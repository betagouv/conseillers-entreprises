# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Search do
  describe 'associations' do
    it { is_expected.to belong_to :user }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :query }
  end

  describe 'scopes' do
    describe 'recent' do
      subject { described_class.recent }

      context 'sorts by creation date' do
        let!(:search1) { create :search, query: 'query' }
        let!(:search2) { create :search, query: 'other query' }
        let!(:search3) { create :search, query: 'yet another query' }

        it { is_expected.to match_array [search3, search2, search1] }
      end

      context 'removes duplicates and keeps most recent' do
        let!(:search1) { create :search, query: 'query' }
        let!(:search2) { create :search, query: 'other query' }
        let!(:search3) { create :search, query: 'query' }

        it { is_expected.to match_array [search3, search2] }
        it { is_expected.not_to include search1 }
      end
    end
  end
end
