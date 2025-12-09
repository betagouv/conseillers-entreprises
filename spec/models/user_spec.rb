require 'rails_helper'

RSpec.describe User do
  describe 'associations' do
    it do
      is_expected.to have_and_belong_to_many :experts
    end
  end

  describe 'validations' do
    describe 'presence' do
      it do
        is_expected.to validate_presence_of(:full_name)
        is_expected.to validate_presence_of(:job)
        is_expected.to validate_presence_of(:email)
      end
    end
  end

  describe 'relations' do
    describe 'expert' do
      context 'user can have many experts' do
        let(:user) { create :user }
        let!(:expert1) { create :expert, users: [user] }
        let!(:expert2) { create :expert, users: [user] }

        it do
          expect(user.experts).to contain_exactly(expert1, expert2)
        end
      end

      context 'user can have no expert' do
        let(:user) { create :user }

        it do
          expect(user.experts).to be_empty
        end
      end
    end
  end

  describe 'soft deletion' do
    subject(:user) { create :user }

    before { user.destroy }

    describe 'deleting user does not really destroy' do
      it { is_expected.to be_deleted }
      it { is_expected.to be_persisted }
      it { is_expected.not_to be_destroyed }
    end

    describe 'deleted users can’t login' do
      it { is_expected.not_to be_active_for_authentication }
    end

    describe 'deleted users get their attributes nilled, and full_name masked' do
      it do
        expect(user[:full_name]).to eq I18n.t('deleted_account.full_name')
        expect(user[:email]).to be_nil
        expect(user[:phone_number]).to be_nil

        expect(user.full_name).not_to be_nil
      end
    end

    describe 'feedbacks and diagnoses of deleted users still have their author / advisor' do
      let(:feedback) { create :feedback, :for_need, user: user }
      let(:diagnosis) { create :diagnosis, advisor: user }

      it do
        expect(feedback.user).to be user
        expect(diagnosis.advisor).to be user
      end
    end
  end

  describe 'scopes' do
    describe 'not_invited' do
      subject { described_class.not_invited }

      let!(:user1) { create :user, invitation_sent_at: nil }
      let!(:user2) { create :user, invitation_sent_at: DateTime.now }

      it{ is_expected.to match_array user1 }
    end

    describe 'rights scopes' do
      let(:user_advisor) { create :user }
      let(:user_manager) { create :user, :manager }
      let(:user_deleted_manager) { create :user, :manager, deleted_at: 1.day.ago }
      let(:user_admin) { create :user, :admin }
      let(:user_poly) { create :user, :admin, :manager }

      subject(:scope) { described_class.send(scope) }

      context 'admin' do
        let(:scope) { :admin }

        it{ is_expected.to contain_exactly(user_admin, user_poly) }
      end

      context 'manager' do
        let(:scope) { :managers }

        it{ is_expected.to contain_exactly(user_manager, user_poly) }
      end
    end

    describe 'omnisearch' do
      let(:user) { create :user, :invitation_accepted, email: 'a.lovelace@example.com', full_name: 'Ada Lovelace' }

      it 'finds by name' do
        expect(described_class.omnisearch("ada")).to contain_exactly(user)
        expect(described_class.omnisearch("dodo")).to be_empty
      end

      it 'finds by email' do
        expect(described_class.omnisearch("lolo@mail.com")).to be_empty
        expect(described_class.omnisearch("a.lovelace")).to contain_exactly(user)
      end
    end

    describe 'with/without activity' do
      let(:inactive_expert) do
        build :expert, received_matches: [
          build(:match, status: :quo),
          build(:match, status: :not_for_me, updated_at: 100.days.ago)
        ]
      end
      let(:active_expert) { build :expert, received_matches: [build(:match, status: :not_for_me, updated_at: 10.days.ago)] }
      let!(:active_user_1) { create :user, experts: [active_expert] }
      let!(:active_user_2) { create :user, experts: [active_expert, inactive_expert] }
      let!(:inactive_user) { create :user, experts: [inactive_expert] }

      it 'returns the relevant users' do
        expect(described_class.with_activity(50.days.ago..)).to contain_exactly(active_user_1, active_user_2)
        expect(described_class.without_activity(50.days.ago..)).to include(inactive_user)
        expect(described_class.without_activity(50.days.ago..)).not_to include(active_user_1, active_user_2)
      end
    end
  end

  describe '#password_required?' do
    subject { user.password_required? }

    context 'new user' do
      let(:user) { create :user }

      it { is_expected.to be_falsey }
    end

    context 'invitation accepted user' do
      let(:user) { create :user, :invitation_accepted }

      it { is_expected.to be_truthy }
    end
  end

  describe '#password_complexity' do
    subject { user.password_complexity }

    context '1 uppercase, 1 lower case, 1 number, 1 special car' do
      let(:user) { build :user, password: 'abAB12;;aaAB12;;' }

      it { is_expected.to be_truthy }
    end

    context '1 uppercase, 1 lower case, 1 number' do
      let(:user) { build :user, password: 'abcABC12abcABC12' }

      it { is_expected.to be_falsey }
    end

    context '1 special car, 1 lower case, 1 number' do
      let(:user) { build :user, password: 'abc***12abc***12' }

      it { is_expected.to be_falsey }
    end

    context '1 special car, 1 lower case, 1 uppercase' do
      let(:user) { build :user, password: 'abcABC°°abcABC°°' }

      it { is_expected.to be_falsey }
    end

    context '1 uppercase, 1 lower case' do
      let(:user) { build :user, password: 'abcdABCDabcdABCD' }

      it { is_expected.to be_falsey }
    end
  end

  describe '#invitation_not_accepted?' do
    subject { user.invitation_not_accepted? }

    context 'blank user' do
      let(:user) { build :user, invitation_accepted_at: nil }

      it{ is_expected.to be_truthy }
    end

    context 'active user' do
      let(:user) { build :user, invitation_accepted_at: DateTime.now }

      it{ is_expected.to be_falsey }
    end
  end

  describe '#managed_antennes' do
    let(:user) { create :user, :manager }

    context "adding a new managed antenne" do
      let(:new_antenne) { create :antenne }

      before do
        user.managed_antennes.push(new_antenne)
      end

      it "lets user manage multiple antennes" do
        expect(user.managed_antennes.size).to eq 2
        expect(new_antenne.advisors).not_to include user
      end
    end
  end

  describe '#supervised_antennes' do
    let(:user) { create :user }
    let!(:regional_antenne) { create :antenne, :regional }
    let!(:local_antenne) { create :antenne, :local, parent_antenne: regional_antenne }

    subject { user.supervised_antennes }

    context "when no manager" do
      it { is_expected.to contain_exactly(user.antenne) }
    end

    context "when local antenne" do
      before { user.user_rights_manager.create(rightable_element: local_antenne) }

      it { is_expected.to contain_exactly(local_antenne) }
    end

    context "when regional antenne" do
      before { user.user_rights_manager.create(rightable_element: regional_antenne) }

      it { is_expected.to contain_exactly(regional_antenne, local_antenne) }
    end
  end

  describe '#duplicate' do
    let(:institution) { create :institution }
    let(:antenne) { create :antenne, institution: institution }
    let(:a_subject) { create :subject }
    let(:institution_subject) { create :institution_subject, institution: institution, subject: a_subject }
    let(:expert_subject) { create :expert_subject, institution_subject: institution_subject }
    let(:old_user) { create :user, :invitation_accepted, :manager, experts: [expert], antenne: antenne, full_name: 'Old User' }

    context 'with team' do
      let(:expert) { create :expert_with_users, experts_subjects: [expert_subject], antenne: antenne }
      let(:new_user) { old_user.duplicate({ full_name: 'New User', email: 'test1@email.com', phone_number: '0303030303' }) }

      it "duplicate a user and add it to old_user team" do
        expect(new_user.full_name).to eq 'New User'
        expect(new_user.email).to eq 'test1@email.com'
        expect(new_user.phone_number).to eq '03 03 03 03 03'
        expect(new_user.job).to eq old_user.job
        expect(new_user.antenne).to eq old_user.antenne
        expect(new_user.antenne.experts.count).to eq 1
        expect(new_user.experts.map { |e| e.subjects }.flatten).to contain_exactly(a_subject)
        expect(new_user.experts).to contain_exactly(expert)
        expect(new_user.user_rights.count).to eq 1
      end
    end
  end

  describe '#support_user' do
    # Si responsable d'une antenne national => referent principal
    # autres cas => referent de l'antenne
    context 'national manager' do
      let(:antenne) { create :antenne, :national }
      let(:manager) { create :user, :manager, antenne: antenne }
      let!(:main_referent) { create :user, :main_referent }

      it do
        expect(manager.support_user).to eq main_referent
      end
    end

    context 'Territorial referent' do
      let!(:territorial_referent) { create :user, :territorial_referent }

      let(:antenne) { create :antenne, :regional, territorial_zones: [create(:territorial_zone, :region, code: "52")] }
      let(:manager) { create :user, :manager, antenne: antenne }

      it do
        expect(manager.support_user).to eq territorial_referent
      end
    end
  end

  describe '#fill_absence_start_at' do
    let(:user) { create :user }

    before { user.update(absence_start_at: absence_start_at, absence_end_at: absence_end_at) }

    context 'no absence' do
      let(:absence_start_at) { nil }
      let(:absence_end_at) { nil }

      it 'doesnt change data' do
        expect(user.absence_start_at&.to_date).to be_nil
        expect(user.absence_end_at&.to_date).to be_nil
      end
    end

    context 'borned absence' do
      let(:absence_start_at) { 10.days.ago }
      let(:absence_end_at) { 5.days.since }

      it 'doesnt change data' do
        expect(user.absence_start_at.to_date).to eq(10.days.ago.to_date)
        expect(user.absence_end_at.to_date).to eq(5.days.since.to_date)
      end
    end

    context 'only end_at set' do
      let(:absence_start_at) { nil }
      let(:absence_end_at) { 15.days.since }

      it 'sets absence start at' do
        expect(user.absence_start_at&.to_date).to eq(Date.today)
        expect(user.absence_end_at.to_date).to eq(15.days.since.to_date)
      end
    end
  end
end
