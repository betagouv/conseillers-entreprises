# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Expert, type: :model do
  describe 'associations' do
    it do
      is_expected.to belong_to :institution
      is_expected.to have_many(:assistances_experts).dependent(:destroy)
      is_expected.to have_many :assistances
      is_expected.to have_many(:expert_territories).dependent(:destroy)
      is_expected.to have_many :territories
      is_expected.to have_many :territory_cities
    end
  end

  describe 'validations' do
    it do
      is_expected.to validate_presence_of(:last_name)
      is_expected.to validate_presence_of(:role)
      is_expected.to validate_presence_of(:institution)
      is_expected.to validate_presence_of(:email)
    end
  end

  describe 'full_name' do
    let(:expert) { build :expert, first_name: 'Ivan', last_name: 'Collombet' }

    it { expect(expert.full_name).to eq 'Ivan Collombet' }
  end

  describe 'to_s' do
    let(:expert) { build :expert, first_name: 'Ivan', last_name: 'Collombet' }

    it { expect(expert.to_s).to eq 'Ivan Collombet' }
  end

  describe 'generate_access_token' do
    let(:expert) { create :expert }

    context 'it is a new expert' do
      context 'there is no expert with this access_token' do
        before { allow(SecureRandom).to receive(:hex).once.and_return('access_token') }

        it { expect(expert.access_token).to eq 'access_token' }
      end

      context 'there is already a expert with this access_token' do
        let!(:expert_with_same_access_token) { create :expert }

        before do
          expert_with_same_access_token.update access_token: 'access_token'
          allow(SecureRandom).to receive(:hex).at_least(:once).and_return('access_token', 'other_access_token')
        end

        it { expect(expert.access_token).to eq 'other_access_token' }
      end
    end

    context 'expert is already created' do
      before do
        allow(SecureRandom).to receive(:hex).once.and_return('access_token')
        expert.save
      end

      it { expect(expert.access_token).to eq 'access_token' }
    end
  end
end
