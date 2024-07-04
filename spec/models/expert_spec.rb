# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Expert do
  describe 'associations' do
    it do
      is_expected.to belong_to :antenne
      is_expected.to have_many(:experts_subjects)
      is_expected.to have_many :received_matches
      is_expected.to have_and_belong_to_many :users
      is_expected.to have_and_belong_to_many :communes
    end
  end

  describe 'validations' do
    describe 'presence' do
      it do
        is_expected.to validate_presence_of(:full_name)
        is_expected.to validate_presence_of(:email)
      end
    end
  end

  describe 'relations' do
    describe 'users' do
      let(:active_user) { create :user, :invitation_accepted }
      let(:deleted_user) { create :user, :invitation_accepted, deleted_at: Time.now }
      let!(:expert) { create :expert, users: [deleted_user, active_user] }

      subject { expert.users }

      before { expert.reload }

      it 'return only not deleted users' do
        is_expected.to match [active_user]
      end
    end
  end

  describe 'team notions' do
    let(:user) { build :user }
    let(:user2) { build :user }

    subject(:expert) { create :expert, users: expert_users }

    context 'an expert with a single is a single user expert' do
      let(:expert_users) { [user2] }

      it do
        is_expected.to be_with_one_user
        is_expected.not_to be_team
        is_expected.not_to be_without_users
        expect(described_class.with_one_user).to include(expert)
        expect(described_class.teams).not_to include(expert)
        expect(described_class.without_users).not_to include(expert)
      end
    end

    context 'an expert with several users is a team' do
      let(:expert_users) { [user, user2] }

      it do
        is_expected.not_to be_with_one_user
        is_expected.to be_team
        is_expected.not_to be_without_users
        expect(described_class.with_one_user).not_to include(expert)
        expect(described_class.teams).to include(expert)
        expect(described_class.without_users).not_to include(expert)
      end
    end

    context 'an expert with no user is neither a team nor a single user expert' do
      let(:expert_users) { [] }

      it do
        is_expected.not_to be_with_one_user
        is_expected.not_to be_team
        is_expected.to be_without_users
        expect(described_class.with_one_user).not_to include(expert)
        expect(described_class.teams).not_to include(expert)
        expect(described_class.without_users).to include(expert)
      end
    end
  end

  describe 'geographical notions' do
    let(:local_expert) { create :expert, antenne: create(:antenne, :local) }
    let(:national_expert) { create :expert, antenne: create(:antenne, :national) }
    let(:global_expert) { create :expert, is_global_zone: true }

    subject { described_class.with_national_perimeter }

    it { is_expected.to contain_exactly(national_expert, global_expert) }
  end

  describe 'a user cannot be member of the same team twice' do
    let(:user) { build :user }
    let(:expert) { build :expert }

    let(:expert_double_user) { create :expert, users: [user, user] }
    let(:user_double_expert) { create :user, experts: [expert, expert] }

    it do
      expect(expert_double_user.users.count).to eq 1
      expect(user_double_expert.experts.count).to eq 1
    end
  end

  describe 'to_s' do
    let(:expert) { build :expert, full_name: 'Ivan Collombet' }

    it { expect(expert.to_s).to eq 'Ivan Collombet' }
  end

  describe 'referencing' do
    describe 'commune zone scopes' do
      let(:expert_with_custom_communes) { create :expert, antenne: antenne, communes: [commune1] }
      let(:expert_without_custom_communes) { create :expert, antenne: antenne }
      let(:commune1) { create :commune }
      let(:commune2) { create :commune }
      let!(:antenne) { create :antenne, communes: [commune1, commune2] }

      describe 'with_custom_communes' do
        subject { described_class.with_custom_communes }

        it { is_expected.to include(expert_with_custom_communes) }
      end

      describe 'without_custom_communes' do
        subject { described_class.without_custom_communes }

        it { is_expected.to include(expert_without_custom_communes) }
      end
    end

    describe 'without_subjects' do
      subject(:expert) { create :expert, experts_subjects: expert_subjects }

      context 'without subject' do
        let(:expert_subjects) { [] }

        it {
          is_expected.to be_without_subjects
          expect(described_class.without_subjects).to include expert
        }
      end

      context 'with subject' do
        let(:expert_subjects) { create_list :expert_subject, 2 }

        it {
          is_expected.not_to be_without_subjects
          expect(described_class.without_subjects).not_to include expert
        }
      end
    end
  end

  describe 'soft deletion' do
    subject(:expert) { create :expert }

    before { expert.destroy }

    describe 'deleting user does not really destroy' do
      it { is_expected.to be_deleted }
      it { is_expected.to be_persisted }
      it { is_expected.not_to be_destroyed }
    end

    describe 'deleted experts get their attributes nilled, and full_name masked' do
      it do
        expect(expert[:full_name]).to eq I18n.t('deleted_account.full_name')
        expect(expert[:email]).to be_nil
        expect(expert[:phone_number]).to be_nil

        expect(expert.full_name).not_to be_nil
      end
    end
  end

  describe 'most_needs_quo_first scope' do
    let!(:expert_with_lots_inbox) { create :expert }
    let!(:expert_with_few_inbox) { create :expert }
    let!(:expert_with_few_taken_care) { create :expert }

    before do
      expert_with_lots_inbox.received_matches << [ create(:match), create(:match) ]
      expert_with_few_inbox.received_matches << [ create(:match), create(:match, status: 'taking_care'), create(:match, status: 'taking_care') ]
      expert_with_few_taken_care.received_matches << [ create(:match, status: 'taking_care'), create(:match, status: 'taking_care') ]
    end

    it 'displays expert in correct order' do
      expect(described_class.most_needs_quo_first.first(2)).to eq [expert_with_lots_inbox, expert_with_few_inbox]
    end
  end
end
