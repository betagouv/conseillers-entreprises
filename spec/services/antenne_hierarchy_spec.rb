require 'rails_helper'

describe AntenneHierarchy do

  describe ".call" do
    let(:institution) { create :institution }
    let!(:national_antenne) { create :antenne, :national, institution: institution }
    let!(:regional_antenne) { create :antenne, :regional, institution: institution, territorial_zones: [create(:territorial_zone, :region, code: "53")] }

    context "National antenne" do
      # Si antenne national on prend les antennes régionales et les antennes locales qui n'ont pas d'antennes régionales
      let!(:local_antenne_witout_regional) { create :antenne, :local, institution: institution, territorial_zones: [create(:territorial_zone, :departement, code: "72")] }
      let!(:local_antenne_with_regional) { create :antenne, :local, institution: institution, parent_antenne: regional_antenne, territorial_zones: [create(:territorial_zone, :departement, code: "22")] }
      let(:antenne) { national_antenne }

      before do
        regional_antenne.update(parent_antenne: national_antenne)
        described_class.new(antenne).call
      end

      it "updates parent_id fo local antennes without regional" do
        expect(local_antenne_witout_regional.reload.parent_antenne_id).to eq(national_antenne.id)
        expect(antenne.child_antennes).to contain_exactly(regional_antenne, local_antenne_witout_regional)
      end
    end

    context 'Regional antenne' do
      let!(:local_antenne_1) { create :antenne, :local, institution: institution, territorial_zones: [create(:territorial_zone, :departement, code: "22")] }
      let!(:local_antenne_2) { create :antenne, :local, institution: institution, territorial_zones: [create(:territorial_zone, :commune, code: "29232")] }
      let(:antenne) { regional_antenne }

      before { described_class.new(antenne).call }

      it "updates parent_id for local antennes" do
        expect(local_antenne_1.reload.parent_antenne).to eq(regional_antenne)
        expect(local_antenne_2.reload.parent_antenne).to eq(regional_antenne)
        expect(antenne.child_antennes).to contain_exactly(local_antenne_1, local_antenne_2)
        expect(antenne.parent_antenne).to eq(national_antenne)
      end
    end

    context "Local antenne" do
      let(:local_antenne) { create :antenne, :local, institution: institution, territorial_zones: [create(:territorial_zone, :commune, code: "29232")] }
      let(:antenne) { local_antenne }

      before { described_class.new(antenne).call }

      it "updates parent with regional antenne" do
        expect(antenne.parent_antenne).to eq(regional_antenne)
      end
    end
  end
end
