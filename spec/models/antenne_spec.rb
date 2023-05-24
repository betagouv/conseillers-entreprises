require 'rails_helper'

RSpec.describe Antenne do
  describe 'relations' do
    describe 'expert' do
      let(:active_expert) { create :expert }
      let(:deleted_expert) { create :expert, deleted_at: Time.now }
      let(:antenne) { create :antenne, experts: [active_expert, deleted_expert] }

      subject { antenne.experts }

      before { antenne.reload }

      it 'return only not deleted experts' do
        is_expected.to match [active_expert]
      end
    end

    describe 'advisor' do
      let(:active_advisor) { create :user }
      let(:deleted_advisor) { create :user, deleted_at: Time.now }
      let(:antenne) { create :antenne, advisors: [active_advisor, deleted_advisor] }

      subject { antenne.advisors }

      before { antenne.reload }

      it 'return only not deleted advisors' do
        is_expected.to match [active_advisor]
      end
    end

    describe 'manager' do
      let(:antenne) { create :antenne }
      let(:manager_antenne) { create :user, :manager, antenne: antenne }

      context 'when adding same antenne manager' do
        let(:same_antenne_manager) { create :user, :manager, antenne: antenne }

        it 'lets antenne have multiple intern managers' do
          expect(antenne.managers).to contain_exactly(manager_antenne, same_antenne_manager)
          expect(same_antenne_manager.antenne).to eq antenne
          expect(manager_antenne.antenne).to eq antenne
        end
      end

      context 'when adding other antenne manager' do
        let(:other_antenne_user) { create :user, antenne: create(:antenne) }

        before { other_antenne_user.managed_antennes.push antenne }

        it 'lets antenne have multiple intern and extern managers' do
          expect(antenne.managers).to contain_exactly(manager_antenne, other_antenne_user)
          expect(other_antenne_user.antenne).not_to eq antenne
          expect(manager_antenne.antenne).to eq antenne
        end
      end
    end
  end

  describe 'name code uniqueness' do
    subject { build :antenne, name: name, institution: institution }

    let(:name) { 'Nice Company Name' }
    let(:other_name) { 'Other Name' }
    let(:institution) { build :institution }
    let(:other_institution) { build :institution }

    context 'unique name' do
      before { create :antenne, name: other_name, institution: institution }

      it { is_expected.to be_valid }
    end

    context 'reused name not deleted antenne' do
      before { create :antenne, name: name, institution: institution }

      it { is_expected.not_to be_valid }
    end

    context 'reused name deleted antenne' do
      before { create :antenne, name: name, institution: institution, deleted_at: Time.now }

      it { is_expected.to be_valid }
    end

    context 'same name, another institution' do
      before { create :antenne, name: name, institution: other_institution }

      it { is_expected.to be_valid }
    end
  end

  describe 'sent_matches' do
    subject { antenne.sent_matches }

    let(:antenne) { build :antenne }

    context 'no match' do
      it { is_expected.to match_array [] }
    end

    context 'match' do
      let(:user) { build :user, antenne: antenne }
      let!(:match) do
        create :match,
               need: build(:need,
                           diagnosis: build(:diagnosis, advisor: user))
      end

      it { is_expected.to contain_exactly(match) }
    end
  end

  describe 'received_matches' do
    subject { antenne.received_matches }

    let(:antenne) { build :antenne }

    context 'no match' do
      it { is_expected.to match_array [] }
    end

    context 'match' do
      let(:expert) { build :expert, antenne: antenne }
      let!(:match) { create :match, expert: expert }

      it { is_expected.to contain_exactly(match) }
    end
  end

  describe 'perimeter_received_needs' do
    let(:commune1) { create :commune }
    let(:commune2) { create :commune }
    let!(:region) { create :territory, :region, code_region: 999, communes: [commune1, commune2] }
    let(:institution1) { create :institution, name: 'Institution 1' }
    let(:national_antenne_i1) { create :antenne, :national, institution: institution1 }
    let(:regional_antenne_i1) { create :antenne, :regional, institution: institution1, communes: [commune1, commune2] }
    let(:local_antenne_i1) { create :antenne, :local, institution: institution1, communes: [commune1] }
    let(:other_local_antenne_i1) { create :antenne, :local, institution: institution1, communes: [commune2] }
    let(:random_local_antenne_i1) { create :antenne, :local, institution: institution1 }
    let(:local_antenne_i2) { create :antenne, :local, institution: create(:institution), communes: [commune1] }

    let(:expert_local_antenne_i1) { create :expert_with_users, antenne: local_antenne_i1 }
    let(:expert_other_local_antenne_i1) { create :expert_with_users, antenne: other_local_antenne_i1 }
    let(:expert_regional_antenne_i1) { create :expert_with_users, antenne: regional_antenne_i1 }
    let(:expert_local_antenne_i2) { create :expert_with_users, antenne: local_antenne_i2 }

    let!(:need_regional_antenne_i1) do
      create :need,
             matches: [create(:match, expert: expert_regional_antenne_i1)],
             diagnosis: create(:diagnosis, facility: create(:facility, commune: commune1))
    end
    let!(:need_local_antenne_i1) do
      create :need,
             matches: [create(:match, expert: expert_local_antenne_i1)],
             diagnosis: create(:diagnosis, facility: create(:facility, commune: commune1))
    end
    let!(:need_other_local_antenne_i1) do
      create :need,
             matches: [create(:match, expert: expert_other_local_antenne_i1)],
             diagnosis: create(:diagnosis, facility: create(:facility, commune: commune2))
    end
    let!(:need_random_local_antenne_i1) do
      create :need,
             matches: [create(:match, expert: create(:expert, antenne: random_local_antenne_i1))]
    end
    let!(:need_local_antenne_i2) do
      create :need,
             matches: [create(:match, expert: expert_local_antenne_i2)],
             diagnosis: create(:diagnosis, facility: create(:facility, commune: commune1))
    end

    before do
      # Je sais pas pourquoi, mais changer le statut a la creation fonctionne pas pour le 2e need
      need_local_antenne_i1.update(status: :quo)
      need_other_local_antenne_i1.update(status: :quo)
    end

    it 'displays only antenne needs for local antennes' do
      expect(local_antenne_i1.perimeter_received_needs).to contain_exactly(need_local_antenne_i1)
      expect(other_local_antenne_i1.perimeter_received_needs).to contain_exactly(need_other_local_antenne_i1)
    end

    it 'displays regional and antenne needs for regional antenne' do
      expect(regional_antenne_i1.perimeter_received_needs).to contain_exactly(need_regional_antenne_i1, need_local_antenne_i1, need_other_local_antenne_i1)
    end

    it 'displays institution needs for national antenne' do
      expect(national_antenne_i1.perimeter_received_needs).to contain_exactly(need_regional_antenne_i1, need_local_antenne_i1, need_other_local_antenne_i1, need_random_local_antenne_i1)
    end
  end

  describe 'perimeter_received_matches_from_needs' do
    let(:commune1) { create :commune }
    let(:commune2) { create :commune }
    let(:commune3) { create :commune }
    let(:institution1) { create :institution, name: 'Institution 1' }
    let!(:region) { create :territory, :region, code_region: 998, communes: [commune1, commune2] }
    let!(:region2) { create :territory, :region, code_region: 999, communes: [commune3] }

    let(:national_antenne_i1) { create :antenne, :national, institution: institution1 }
    let(:regional_antenne_i1) { create :antenne, :regional, institution: institution1, communes: [commune1, commune2] }
    let(:regional_antenne2_i1) { create :antenne, :regional, institution: institution1, communes: [commune3] }
    let(:local_antenne_i1) { create :antenne, :local, institution: institution1, communes: [commune1] }
    let(:other_local_antenne_i1) { create :antenne, :local, institution: institution1, communes: [commune2] }
    let(:random_local_antenne_i1) { create :antenne, :local, institution: institution1 }
    let(:local_antenne_i2) { create :antenne, :local, institution: create(:institution), communes: [commune1] }

    let(:expert_local_antenne_i1) { create :expert_with_users, antenne: local_antenne_i1 }
    let(:expert_other_local_antenne_i1) { create :expert_with_users, antenne: other_local_antenne_i1 }
    let(:expert_regional_antenne_i1) { create :expert_with_users, antenne: regional_antenne_i1 }
    let(:expert_regional_antenne2_i1) { create :expert_with_users, antenne: regional_antenne2_i1 }
    let(:expert_local_antenne_i2) { create :expert_with_users, antenne: local_antenne_i2 }

    let(:need1) { create :need_with_matches }
    let(:need2) { create :need_with_matches }
    let(:need3) { create :need_with_matches }
    let(:need4) { create :need_with_matches }

    let!(:regional_antenne_i1_match) { create :match, need: need1, expert: expert_regional_antenne_i1 }
    let!(:regional_antenne2_i1_match) { create :match, need: need4, expert: expert_regional_antenne2_i1 }
    let!(:local_antenne_i1_match) { create :match, need: need2, expert: expert_local_antenne_i1 }
    let!(:other_local_antenne_i1_match) { create :match, need: need3, expert: expert_other_local_antenne_i1 }
    let!(:random_local_antenne_i1_match) { create :match, need: need3, expert: create(:expert, antenne: random_local_antenne_i1) }
    let!(:local_antenne_i2_match) { create :match, need: need2, expert: expert_local_antenne_i2 }

    it 'displays only antenne matches for local antennes' do
      expect(local_antenne_i1.perimeter_received_matches_from_needs([need1, need2, need3, need4])).to contain_exactly(local_antenne_i1_match)
      expect(other_local_antenne_i1.perimeter_received_matches_from_needs([need1, need2, need3, need4])).to contain_exactly(other_local_antenne_i1_match)
    end

    it 'displays regional and antenne matches for regional antenne' do
      expect(regional_antenne_i1.perimeter_received_matches_from_needs([need1, need2, need3, need4])).to contain_exactly(regional_antenne_i1_match, local_antenne_i1_match, other_local_antenne_i1_match)
    end

    it 'displays institution matches for national antenne' do
      expect(national_antenne_i1.perimeter_received_matches_from_needs([need1, need2, need3, need4])).to contain_exactly(regional_antenne_i1_match, regional_antenne2_i1_match, local_antenne_i1_match, other_local_antenne_i1_match, random_local_antenne_i1_match)
    end
  end

  describe 'by_antenne_and_institution_names' do
    subject(:result) { described_class.by_antenne_and_institution_names(query) }

    let(:query) { [['Agence Douai', 'Pôle emploi'], ['Agence Cambrai', 'CMA']] }

    let(:pe) { create :institution, name: 'Pôle emploi' }
    let(:cma) { create :institution, name: 'CMA' }
    let(:a1) { create :antenne, name: 'Agence Douai', institution: pe }
    let(:a2) { create :antenne, name: 'Agence Cambrai', institution: pe }
    let(:a3) { create :antenne, name: 'Agence Douai', institution: cma }
    let(:a4) { create :antenne, name: 'Agence Cambrai', institution: cma }

    before { [a1, a2, a3, a4] }

    it { is_expected.to contain_exactly(a1, a4) }
  end

  describe 'regional_antenne' do
    let(:commune1) { create :commune }
    let(:commune2) { create :commune }
    let!(:region) { create :territory, :region, code_region: 999, communes: [commune1, commune2] }
    let(:institution1) { create :institution, name: 'Institution 1' }
    let!(:regional_antenne1) { create :antenne, :regional, institution: institution1, communes: [commune1, commune2] }
    let!(:local_antenne1) { create :antenne, :local, institution: institution1, communes: [commune1] }
    let!(:other_local_antenne1) { create :antenne, :local, institution: institution1, communes: [commune2] }
    let!(:out_local_antenne1) { create :antenne, :local, institution: institution1, communes: [create(:commune)] }
    let!(:local_antenne2) { create :antenne, :local, institution: create(:institution), communes: [commune1] }

    it "returns correct regional_antenne" do
      expect(regional_antenne1.regional_antenne).to be_nil
      expect(local_antenne1.regional_antenne).to eq regional_antenne1
      expect(other_local_antenne1.regional_antenne).to eq regional_antenne1
      expect(out_local_antenne1.regional_antenne).not_to eq regional_antenne1
      expect(local_antenne2.regional_antenne).not_to eq regional_antenne1
    end

    it "returns correct local antennes" do
      expect(regional_antenne1.territorial_antennes).to contain_exactly(local_antenne1, other_local_antenne1)
      expect(local_antenne1.territorial_antennes).to be_empty
    end
  end

  describe 'check_territorial_level callback' do
    let!(:commune1) { create :commune }
    let!(:commune2) { create :commune }
    let!(:region) { create :territory, :region, code_region: 999, communes: [commune1, commune2] }
    let!(:regional_antenne1) { create :antenne, communes: [commune1, commune2] }
    let!(:local_antenne1) { create :antenne, communes: [commune1] }

    it 'sets regional_antenne as regional' do
      expect(regional_antenne1.regional?).to be true
    end

    it 'doesnt set regional_antenne as regional' do
      expect(local_antenne1.regional?).to be false
    end
  end
end
