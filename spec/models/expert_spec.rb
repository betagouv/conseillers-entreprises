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

    context 'an expert with a single user is a single user expert' do
      let(:expert_users) { [user2] }

      it do
        is_expected.to be_with_one_user
        is_expected.not_to be_without_users
        expect(described_class.with_one_user).to include(expert)
        expect(described_class.without_users).not_to include(expert)
      end
    end

    context 'an expert with no user is neither a team nor a single user expert' do
      let(:expert_users) { [] }

      it do
        is_expected.not_to be_with_one_user
        is_expected.to be_without_users
        expect(described_class.with_one_user).not_to include(expert)
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

  describe 'scopes' do
    describe 'territorial zones scopes' do
      let(:expert_with_custom_territories) { create :expert, antenne: antenne, territorial_zones: [territorial_zone] }
      let(:expert_without_custom_territories) { create :expert, antenne: antenne }
      let(:territorial_zone) { create :territorial_zone, :commune }
      let!(:antenne) { create :antenne, territorial_zones: [territorial_zone] }

      describe 'with_custom_communes' do
        subject { described_class.with_territorial_zones }

        it { is_expected.to include(expert_with_custom_territories) }
      end

      describe 'without_custom_communes' do
        subject { described_class.without_territorial_zones }

        it { is_expected.to include(expert_without_custom_territories) }
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

    describe 'with_activity / without_activity' do
      let!(:inactive_expert) do
        create :expert, received_matches: [
          build(:match, status: :quo),
          build(:match, status: :not_for_me, updated_at: 100.days.ago)
        ]
      end
      let!(:active_expert) { create :expert, received_matches: [build(:match, status: :not_for_me, updated_at: 10.days.ago)] }

      it 'returns the relevant experts' do
        expect(described_class.with_activity(50.days.ago..)).to contain_exactly(active_expert)
        expect(described_class.without_activity(50.days.ago..)).to contain_exactly(inactive_expert)
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

  describe '#reassign matches' do
    let(:old_expert) { create :expert, :with_expert_subjects }
    let(:new_expert) { create :expert, :with_expert_subjects }
    let!(:match_quo) { create :match, status: :quo, expert: old_expert }
    let!(:match_taking_care) { create :match, status: :taking_care, expert: old_expert }
    let!(:match_done) { create :match, status: :done, expert: old_expert }

    before { old_expert.transfer_in_progress_matches(new_expert) }

    it 'transfers only in progress matches to new expert' do
      expect(new_expert.received_matches).to contain_exactly(match_quo, match_taking_care)
      expect(old_expert.received_matches).not_to include(match_quo, match_taking_care)
      expect(old_expert.received_matches).to include(match_done)
    end
  end

  describe 'with_taking_care_stock' do
    let(:expert_with_taking_care_stock) { create :expert }
    let(:expert_with_other_stock) { create :expert }
    let(:expert_with_recent_taking_care_stock) { create :expert }
    let(:expert_with_low_taking_care_stock) { create :expert }

    before do
      6.times do |index|
        create(:match, expert: expert_with_taking_care_stock, status: :taking_care, created_at: 1.month.ago, taken_care_of_at: 40.days.ago)
      end
      6.times do |index|
        create(:match, expert: expert_with_other_stock, status: :quo, created_at: 1.month.ago, taken_care_of_at: 40.days.ago)
      end
      6.times do |index|
        create(:match, expert: expert_with_recent_taking_care_stock, status: :taking_care, created_at: 1.month.ago, taken_care_of_at: 10.days.ago)
      end
      4.times do |index|
        create(:match, expert: expert_with_low_taking_care_stock, status: :taking_care, created_at: 1.month.ago, taken_care_of_at: 40.days.ago)
      end
    end

    it 'selects concerned experts' do
      expect(described_class.with_taking_care_stock).to contain_exactly(expert_with_taking_care_stock)
    end
  end

  describe "in_commune" do
    # Commune 47204 : Penne-d'Agenais
    # EPCI 200068930 : Communauté de communes Fumel Vallée du Lot
    # Département 47 : Lot-et-Garonne
    # Région 75 : Nouvelle-Aquitaine

    let(:insee_code) { "47203" }

    subject { described_class.in_commune(insee_code) }

    def expect_expert_with_commune
      expect(subject).to contain_exactly(expert_with_code)
      expect(subject).not_to include(expert_without_code)
      expect(subject.count).to eq 1
    end

    context "Expert sans territoire spécifique" do
      context "Commune directe" do
        let(:antenne_with_code) { create :antenne, territorial_zones: [create(:territorial_zone, :commune, code: insee_code)] }
        let!(:expert_with_code) { create :expert, :with_expert_subjects, antenne: antenne_with_code }
        let(:antenne_without_code) { create :antenne, territorial_zones: [create(:territorial_zone, :commune, code: "72026")] }
        let!(:expert_without_code) { create :expert, :with_expert_subjects }

        it { expect_expert_with_commune }
      end

      context "EPCI qui a la commune" do
        let(:antenne_with_code) { create :antenne, territorial_zones: [create(:territorial_zone, :epci, code: "200068930")] }
        let!(:expert_with_code) { create :expert, :with_expert_subjects, antenne: antenne_with_code }
        let(:antenne_without_code) { create :antenne, territorial_zones: [create(:territorial_zone, :epci, code: "200054781")] }
        let!(:expert_without_code) { create :expert, :with_expert_subjects, antenne: antenne_without_code }

        it { expect_expert_with_commune }
      end

      context "Département qui a la commune" do
        let(:antenne_with_code) { create :antenne, territorial_zones: [create(:territorial_zone, :departement, code: "47")] }
        let!(:expert_with_code) { create :expert, :with_expert_subjects, antenne: antenne_with_code }
        let(:antenne_without_code) { create :antenne, territorial_zones: [create(:territorial_zone, :departement, code: "72")] }
        let!(:expert_without_code) { create :expert, :with_expert_subjects, antenne: antenne_without_code }

        it { expect_expert_with_commune }
      end

      context "Région qui a la commune" do
        let(:antenne_with_code) { create :antenne, territorial_zones: [create(:territorial_zone, :region, code: "75")] }
        let!(:expert_with_code) { create :expert, :with_expert_subjects, antenne: antenne_with_code }
        let(:antenne_without_code) { create :antenne, territorial_zones: [create(:territorial_zone, :region, code: "76")] }
        let!(:expert_without_code) { create :expert, :with_expert_subjects, antenne: antenne_without_code }

        it { expect_expert_with_commune }
      end

      context "Expert national" do
        let(:antenne) { create :antenne }
        let!(:expert_with_code) { create :expert, :with_expert_subjects, is_global_zone: true, antenne: antenne }
        let!(:expert_without_code) { create :expert, :with_expert_subjects }

        it { expect_expert_with_commune }
      end

    end

    context "Expert avec des territoires spécifiques" do
      context "Commune directe" do
        let!(:expert_with_code) { create :expert, :with_expert_subjects, territorial_zones: [create(:territorial_zone, :commune, code: insee_code)] }
        let!(:expert_without_code) { create :expert, :with_expert_subjects, territorial_zones: [create(:territorial_zone, :commune, code: "72026")] }

        it { expect_expert_with_commune }
      end

      context "EPCI qui a la commune" do
        let!(:expert_with_code) { create :expert, :with_expert_subjects, territorial_zones: [create(:territorial_zone, :epci, code: "200068930")] }
        let!(:expert_without_code) { create :expert, :with_expert_subjects, territorial_zones: [create(:territorial_zone, :epci, code: "200054781")] }

        it { expect_expert_with_commune }
      end

      context "Département qui a la commune" do
        let!(:expert_with_code) { create :expert, :with_expert_subjects, territorial_zones: [create(:territorial_zone, :departement, code: "47")] }
        let!(:expert_without_code) { create :expert, :with_expert_subjects, territorial_zones: [create(:territorial_zone, :departement, code: "72")] }

        it { expect_expert_with_commune }
      end

      context "Région qui a la commune" do
        let!(:expert_with_code) { create :expert, :with_expert_subjects, territorial_zones: [create(:territorial_zone, :region, code: "75")] }
        let!(:expert_without_code) { create :expert, :with_expert_subjects, territorial_zones: [create(:territorial_zone, :region, code: "76")] }

        it { expect_expert_with_commune }
      end

      context "Expert national" do
        let!(:expert_with_code) { create :expert, :with_expert_subjects, is_global_zone: true }
        let!(:expert_without_code) { create :expert, :with_expert_subjects }

        it { expect_expert_with_commune }
      end
    end

    context "Expert avec territoires spécifiques mais dont l'antenne couvre la commune" do
      # Bug fix: Un expert avec des zones spécifiques qui ne couvrent PAS la commune
      # ne doit PAS ressortir même si son antenne couvre cette commune.
      # Avant le fix, l'expert ressortait à tort car le scope n'excluait pas
      # les experts avec zones spécifiques de la recherche basée sur l'antenne.

      let(:insee_code) { "35294" } # Sainte-Marie, Ille-et-Vilaine
      # Cette commune est dans le département 35, EPCI 243500741

      # Antenne qui couvre tout le département 35
      let(:antenne_dept_35) { create :antenne, territorial_zones: [create(:territorial_zone, :departement, code: "35")] }

      # Expert sans zones spécifiques : devrait ressortir (hérite de l'antenne)
      let!(:expert_without_zones) { create :expert, :with_expert_subjects, antenne: antenne_dept_35 }

      # Expert avec zones spécifiques (autres communes du 35) : ne devrait PAS ressortir
      # car ses zones ne couvrent pas la commune 35294
      let!(:expert_with_other_zones) do
        create :expert, :with_expert_subjects, antenne: antenne_dept_35, territorial_zones: [
          create(:territorial_zone, :commune, code: "35001"), # Acigné
          create(:territorial_zone, :commune, code: "35051")  # Cesson-Sévigné
        ]
      end

      subject { described_class.in_commune(insee_code) }

      it "n'inclut pas l'expert avec zones spécifiques qui ne couvrent pas la commune" do
        expect(subject).to include(expert_without_zones)
        expect(subject).not_to include(expert_with_other_zones)
        expect(subject.count).to eq 1
      end
    end

    context "when insee_code is nil" do
      let(:insee_code) { nil }

      it "returns an empty relation" do
        expect(subject).to be_empty
        expect(subject.count).to eq 0
      end
    end

    context "when insee_code is empty string" do
      let(:insee_code) { "" }

      it "returns an empty relation" do
        expect(subject).to be_empty
        expect(subject.count).to eq 0
      end
    end

    context "when insee_code is invalid" do
      let(:insee_code) { "99999" }

      it "returns an empty relation" do
        expect(subject).to be_empty
        expect(subject.count).to eq 0
      end
    end
  end

  describe '#with_identical_user?' do
    let(:user) { build :user, email: 'numerobis@architecte.com', full_name: 'Numérobis' }
    let(:expert) { build :expert, email: 'numerobis@architecte.com', full_name: 'Numérobis', users: [user] }

    subject { expert.with_identical_user? }

    context 'when expert has one user with identical email and full name' do
      it { expect(expert).to be_with_identical_user }
    end

    context 'when expert has one user with different email' do
      before { user.email = 'otis@scribe.com' }

      it { expect(expert).not_to be_with_identical_user }
    end

    context 'when expert has one user with different full name' do
      before { user.full_name = 'Otis' }

      it { expect(expert).not_to be_with_identical_user }
    end

    context 'when expert has no users' do
      before { expert.users = [] }

      it { expect(expert).not_to be_with_identical_user }
    end

    context 'when expert has multiple users' do
      let(:user2) { build :user, email: 'amonbofis@architecte.com', full_name: 'Amonbofis' }

      before { expert.users << user2 }

      it { expect(expert).not_to be_with_identical_user }
    end
  end
end
