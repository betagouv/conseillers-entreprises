# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Relay, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :territory
      is_expected.to belong_to :user
      is_expected.to validate_presence_of :territory
      is_expected.to validate_presence_of :user
    end
  end

  describe 'territory uniqueness in the scope of a user' do
    subject { build :relay, user: user, territory: territory }

    let(:user) { create :user }
    let(:territory) { create :territory }

    context 'unique user administrator for this territory' do
      it { is_expected.to be_valid }
    end

    context 'user administrator for another territory' do
      before { create :relay, user: user }

      it { is_expected.to be_valid }
    end

    context 'user administrator for the same territory' do
      before { create :relay, user: user, territory: territory }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'associations dependencies' do
    let(:relay) { create :relay }

    context 'with an assigned match' do
      before { create :match, relay: relay }

      it {
        expect{ relay.destroy! }.not_to raise_error
      }
    end
  end
end
