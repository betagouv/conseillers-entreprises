# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Search, type: :model do
  it { is_expected.to belong_to :user }
  it { is_expected.to validate_presence_of :user }

  describe 'scopes' do
    describe 'last_queries_of_user' do
      subject { Search.last_queries_of_user user }

      let(:user) { build :user }

      before { create :search, user: user, query: '1' }

      context 'only one query' do
        it { is_expected.to eq ['1'] }
      end

      context 'two times the same query' do
        before { create :search, user: user, query: '1' }

        it { is_expected.to eq ['1'] }
      end
    end
  end
end
