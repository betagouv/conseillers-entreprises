# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it do
      is_expected.to have_many :relays
      is_expected.to have_many :relay_territories
      is_expected.to have_and_belong_to_many :experts
    end
  end

  describe 'validations' do
    describe 'presence' do
      it do
        is_expected.to validate_presence_of(:full_name)
        is_expected.to validate_presence_of(:role)
        is_expected.to validate_presence_of(:phone_number)
      end
    end

    describe 'emails' do
      it do
        is_expected.to validate_presence_of(:email)
        is_expected.to allow_value('test@beta.gouv.fr').for(:email)
        is_expected.not_to allow_value('test').for(:email)
      end
    end

    describe 'passwords' do
      it do
        is_expected.to validate_presence_of(:password)
        is_expected.not_to allow_value('short').for(:password)
      end
    end
  end

  describe 'associations dependencies' do
    let(:user) { create :user }

    context 'with a search history' do
      before { create :search, user: user }

      it {
        expect{ user.destroy! }.not_to raise_error
      }
    end
  end

  describe 'scopes' do
    describe 'ordered_for_contact' do
      it do
        user1 = create :user, contact_page_order: 1
        create(:relay, user: user1, territory: create(:territory, name: 'aa'))
        user2 = create :user, contact_page_order: 2
        create(:relay, user: user2, territory: create(:territory, name: 'bb'))
        user3 = create :user, contact_page_order: 1
        user4 = create :user, contact_page_order: 2

        expect(User.ordered_for_contact).to eq [user1, user2, user3, user4]
      end
    end

    describe 'relays' do
      it do
        user1 = create :user
        create(:relay, user: user1)
        user2 = create :user
        create(:relay, user: user2)
        user3 = create :user, is_admin: true
        create :relay, user: user3

        expect(User.relays).to match_array [user1, user2]
      end
    end

    describe 'not_admin' do
      it do
        create :user, is_admin: true
        regular_user = create :user, is_admin: false

        expect(User.not_admin).to eq [regular_user]
      end
    end

    describe 'active_searchers' do
      it do
        searcher = create :user, searches: [(create :search, created_at: 1.day.ago)]
        create :user, searches: [(create :search, created_at: 2.months.ago)]

        last_30_days = (30.days.ago)..Time.zone.now
        expect(User.active_searchers(last_30_days)).to eq [searcher]
      end
    end

    describe 'active_diagnosers' do
      it do
        diagnosis = create :diagnosis, created_at: 1.day.ago, step: 3
        diagnoser = create :user, sent_diagnoses: [diagnosis]

        last_30_days = (30.days.ago)..Time.zone.now

        expect(User.active_diagnosers(last_30_days, 3)).to eq [diagnoser]
        expect(User.active_diagnosers(last_30_days, 4)).to eq []
      end
    end

    describe 'active_answered' do
      it do
        expert = create :match, status: 2
        need = create :diagnosed_need, matches: [expert]
        diagnosis = create :diagnosis, created_at: 1.day.ago, diagnosed_needs: [need]
        active_user = create :user, sent_diagnoses: [diagnosis]

        last_30_days = (30.days.ago)..Time.zone.now

        expect(User.active_answered(last_30_days, [1,2])).to eq [active_user]
        expect(User.active_answered(last_30_days, [3])).to eq []
      end
    end
  end

  describe 'full_name_with_role' do
    let(:user) do
      build :user,
        full_name: 'Ivan Collombet',
        role: 'Business Developer',
        antenne: build(:antenne, name: 'DINSIC')
    end

    it { expect(user.full_name_with_role).to eq 'Ivan Collombet (Business Developer - DINSIC)' }
  end

  describe '#auto_approve_if_whitelisted_domain callback' do
    subject { user.is_approved? }

    let(:user) { create(:user, :just_registered, email: email) }

    context 'with an unkown email domain' do
      let(:email) { 'user@example.com' }

      it { is_expected.to be_falsey }
    end

    context 'with a kown email domain' do
      let(:email) { 'user@beta.gouv.fr' }

      it { is_expected.to be_truthy }
    end
  end

  describe '#corresponding_experts' do
    subject { user.corresponding_experts }

    let(:user) { create(:user, :just_registered, email: 'user@example.com') }

    before { create :expert, email: expert_email }

    context ('with a corresponding email') do
      let(:expert_email) { 'user@example.com' }

      it { is_expected.not_to be_empty }
    end

    context ('with a different email') do
      let(:expert_email) { 'lol@nope.com' }

      it { is_expected.to be_empty }
    end
  end

  describe '#corresponding_antenne' do
    subject { user.corresponding_antenne }

    let(:user) { create(:user, email: 'user@example.com', institution: 'DINSIC') }
    let!(:antenne) { create :antenne, name: antenne_name }

    context ('matching by experts email') do
      let(:antenne_name) { 'other' }

      before { create :expert, email: expert_email, antenne: antenne }

      context ('with a corresponding email') do
        let(:expert_email) { 'user@example.com' }

        it { is_expected.to eq antenne }
      end

      context ('with a different email') do
        let(:expert_email) { 'lol@nope.com' }

        it { is_expected.to be_nil }
      end

      context ('with several matching email') do
        let(:expert_email) { 'user@example.com' }

        before { create(:expert, email: expert_email, antenne: create(:antenne)) }

        it { is_expected.to be_nil }
      end
    end

    context ('matching by antenne name') do
      context ('with a corresponding name') do
        let(:antenne_name) { 'DINSIC' }

        it { is_expected.to eq antenne }
      end

      context ('with a partially matching name') do
        let(:antenne_name) { 'DINSIC (Services du PM)' }

        it { is_expected.to eq antenne }
      end

      context ('with a different name') do
        let(:antenne_name) { 'other' }

        it { is_expected.to be_nil }
      end

      context ('with several matching names') do
        let(:antenne_name) { 'DINSIC' }

        before { create :antenne, name: 'DINSIC 2' }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#is_oneself?' do
    subject { user.is_oneself? }

    let(:user) { create(:user) }
    let(:user2) { create(:user) }
    let(:expert1) { create(:expert) }
    let(:expert2) { create(:expert) }

    context ('with no expert') do
      before { user.experts = [] }

      it { is_expected.to be_falsey }
    end

    context ('with one expert') do
      before { user.experts = [expert1] }

      it { is_expected.to be_truthy }
    end

    context ('with several experts') do
      before { user.experts = [expert1, expert2] }

      it { is_expected.to be_falsey }
    end

    context ('with one expert, several users') do
      before { expert1.users = [user, user2] }

      it { is_expected.to be_falsey }
    end
  end
end
