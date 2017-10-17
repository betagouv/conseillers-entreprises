# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TerritoryUser, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :territory
      is_expected.to belong_to :user
      is_expected.to validate_presence_of :territory
      is_expected.to validate_presence_of :user
    end
  end

  describe 'territory uniqueness in the scope of a user' do
    subject { build :territory_user, user: user, territory: territory }

    let(:user) { create :user }
    let(:territory) { create :territory }

    context 'unique user administrator for this territory' do
      it { is_expected.to be_valid }
    end

    context 'user administrator for another territory' do
      before { create :territory_user, user: user }

      it { is_expected.to be_valid }
    end

    context 'user administrator for the same territory' do
      before { create :territory_user, user: user, territory: territory }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'scopes' do
    describe 'of_diagnosis_location' do
      subject { described_class.of_diagnosis_location(diagnosis) }

      let(:facility) { create :facility, city_code: '59123' }
      let(:visit) { create :visit, facility: facility }
      let(:diagnosis) { create :diagnosis, visit: visit }

      let(:territory) { create :territory }
      let!(:territory_user) { create :territory_user, territory: territory }

      before { create :territory_city, territory: territory, city_code: '59123' }

      it { is_expected.to eq [territory_user] }
    end
  end
end
