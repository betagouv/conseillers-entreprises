require 'rails_helper'
RSpec.describe UpdateAntenneHierarchyJob do

  describe "perform" do
    let(:institution1) { create :institution, name: 'Institution 1' }
    let!(:national_antenne_i1) { create :antenne, :national, institution: institution1 }
    let!(:regional_antenne_i1) { create :antenne, :regional, institution: institution1, territorial_zones: [create(:territorial_zone, :region, code: "53")] }
    let!(:local_antenne_i1) { create :antenne, :local, institution: institution1, territorial_zones: [create(:territorial_zone, :commune, code: "22004")] }
    let!(:other_local_antenne_i1) { create :antenne, :local, institution: institution1, territorial_zones: [create(:territorial_zone, :commune, code: "22013")] }
    let!(:local_antenne_without_regional_i1) { create :antenne, :local, institution: institution1, territorial_zones: [create(:territorial_zone, :commune, code: "72110")] }
    let!(:local_antenne_i2) { create :antenne, :local, institution: create(:institution), territorial_zones: [create(:territorial_zone, :commune, code: "22004")] }

    describe 'national antenne' do
      before do
        described_class.perform_sync(national_antenne_i1.id)
        national_antenne_i1.reload
      end

      it 'sets hierarchy' do
        expect(national_antenne_i1.parent_antenne).to be_nil
        expect(national_antenne_i1.child_antennes).to contain_exactly(regional_antenne_i1, local_antenne_without_regional_i1)
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
