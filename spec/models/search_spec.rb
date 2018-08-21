# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Search, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to :user }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
  end

  describe 'scopes' do
    describe 'recent' do
      subject { Search.recent }

      let!(:search1) { create :search }
      let!(:search2) { create :search }
      let!(:search3) { create :search }

      it { is_expected.to eq [search3, search2, search1] }
    end
  end
end
