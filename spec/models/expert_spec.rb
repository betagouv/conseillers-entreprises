# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Expert, type: :model do
  describe 'associations' do
    it do
      is_expected.to belong_to :local_office
      is_expected.to have_many(:assistances_experts).dependent(:destroy)
      is_expected.to have_many :assistances
      is_expected.to have_many(:expert_territories).dependent(:destroy)
      is_expected.to have_many :territories
      is_expected.to have_many :territory_cities
      is_expected.to have_and_belong_to_many :users
    end
  end

  describe 'validations' do
    describe 'presence' do
      it do
        is_expected.to validate_presence_of(:full_name)
        is_expected.to validate_presence_of(:role)
        is_expected.to validate_presence_of(:local_office)
        is_expected.to validate_presence_of(:email)
      end
    end

    describe 'email format' do
      it do
        is_expected.to allow_value('test@beta.gouv.fr').for(:email)
        is_expected.to allow_value('0_@1-.2').for(:email)
        is_expected.not_to allow_value('test').for(:email)
        is_expected.not_to allow_value('te@st').for(:email)
      end
    end
  end

  describe 'associations dependencies' do
    let(:expert) { create :expert }
    let(:assistance) { create :assistance }
    let(:ae) { create :assistance_expert, expert: expert, assistance: assistance }

    before do
      create :match, assistance_expert: ae
    end

    context 'when removing an assistance' do
      it {
        expect{ expert.assistances = [] }.not_to raise_error
        expect(expert.assistances).to eq []
      }
    end
  end

  describe 'scopes' do
    describe 'of_city_code' do
      subject { Expert.of_city_code city_code }

      let(:city_code) { '59003' }
      let(:maubeuge_expert) { create :expert }
      let(:maubeuge_experts) { [maubeuge_expert] }
      let(:maubeuge_territory) { create :territory, name: 'Maubeuge', experts: maubeuge_experts }

      before do
        create :territory, name: 'Valenciennes', experts: [maubeuge_expert]
        create :territory_city, territory: maubeuge_territory, city_code: '59003'
        create :territory_city, territory: maubeuge_territory, city_code: '59006'
      end

      context 'one expert' do
        it { is_expected.to eq [maubeuge_expert] }
      end

      context 'several experts' do
        let(:other_maubeuge_expert) { create :expert }
        let(:maubeuge_experts) { [maubeuge_expert, other_maubeuge_expert] }

        it { is_expected.to match_array [maubeuge_expert, other_maubeuge_expert] }
      end

      context 'city code in neither' do
        let(:city_code) { '75108' }

        it { is_expected.to be_empty }
      end
    end
  end

  describe 'to_s' do
    let(:expert) { build :expert, full_name: 'Ivan Collombet' }

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
