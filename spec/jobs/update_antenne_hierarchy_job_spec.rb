require 'rails_helper'
RSpec.describe UpdateAntenneHierarchyJob do

  describe "perform" do
    let(:commune1) { create :commune }
    let(:commune2) { create :commune }
    let(:region) { create :territory, :region, code_region: 999, communes: [commune1, commune2] }
    let(:institution1) { create :institution, name: 'Institution 1' }

    let!(:national_antenne_i1) { create :antenne, :national, institution: institution1 }
    let!(:regional_antenne_i1) { create :antenne, :regional, institution: institution1, communes: [commune1, commune2] }
    let!(:local_antenne_i1) { create :antenne, :local, institution: institution1, communes: [commune1] }
    let!(:other_local_antenne_i1) { create :antenne, :local, institution: institution1, communes: [commune2] }
    let!(:random_local_antenne_i1) { create :antenne, :local, institution: institution1 }
    let!(:local_antenne_i2) { create :antenne, :local, institution: create(:institution), communes: [commune1] }

    describe 'national antenne' do
      before do
        described_class.perform_sync(national_antenne_i1.id)
        national_antenne_i1.reload
      end

      it 'sets hierarchy' do
        expect(national_antenne_i1.parent_antenne).to be_nil
        expect(national_antenne_i1.child_antennes).to contain_exactly(regional_antenne_i1)
      end
    end

    describe 'regional antenne' do
      before do
        described_class.perform_sync(regional_antenne_i1.id)
        regional_antenne_i1.reload
      end

      it 'sets hierarchy' do
        expect(regional_antenne_i1.parent_antenne).to eq(national_antenne_i1)
        expect(regional_antenne_i1.child_antennes).to contain_exactly(local_antenne_i1, other_local_antenne_i1)
      end
    end

    describe 'local antenne' do
      before do
        described_class.perform_sync(local_antenne_i1.id)
        local_antenne_i1.reload
      end

      it 'sets hierarchy' do
        expect(local_antenne_i1.parent_antenne).to eq(regional_antenne_i1)
        expect(local_antenne_i1.child_antennes).to eq([])
      end
    end
  end
end
