require 'rails_helper'

describe RecordExtensions::HumanCount do
  describe 'human_count' do
    subject { user.searches.human_count }

    let(:user) { create :user, searches: create_list(:search, search_count) }

    context 'one object' do
      let(:search_count) { 1 }

      it { is_expected.to eq '1 recherche' }
    end

    context 'zero objects' do
      let(:search_count) { 0 }

      it { is_expected.to eq '0 recherche' }
    end

    context 'several objects' do
      let(:search_count) { 4 }

      it { is_expected.to eq '4 recherches' }
    end
  end
end
