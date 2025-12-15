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

      context 'when local antennes outside regional perimeter have wrong parent' do
        # Test pour le bug où des antennes locales en dehors du périmètre
        # de l'antenne régionale avaient quand même cette antenne comme parent
        let!(:local_antenne_outside_perimeter) do
          create :antenne, :local, institution: institution,
                 territorial_zones: [create(:territorial_zone, :departement, code: "75")],
                 parent_antenne: regional_antenne
        end

        before { described_class.new(antenne).call }

        it "removes parent_id for local antennes outside perimeter" do
          expect(local_antenne_outside_perimeter.reload.parent_antenne_id).to be_nil
          expect(antenne.child_antennes).to contain_exactly(local_antenne_1, local_antenne_2)
          expect(antenne.child_antennes).not_to include(local_antenne_outside_perimeter)
        end
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

    context 'with global zone experts' do
      let!(:local_antenne_with_global_expert) do
  create :antenne, :local, institution: institution,
                                                 territorial_zones: [create(:territorial_zone, :departement, code: "75")],
                                                 experts: [create(:expert, antenne: antenne, is_global_zone: true)]
end
      let(:antenne) { regional_antenne }

      before { described_class.new(antenne).call }

      it "includes antennes with global zone experts even outside perimeter" do
        expect(local_antenne_with_global_expert.reload.parent_antenne).to eq(regional_antenne)
        expect(antenne.child_antennes).to include(local_antenne_with_global_expert)
      end
    end

    context 'when cleaning wrong parent relationships for national antenne' do
      let!(:regional_from_other_institution) { create :antenne, :regional, institution: create(:institution) }
      let!(:regional_with_wrong_parent) do
        create :antenne, :regional, institution: institution,
               territorial_zones: [create(:territorial_zone, :region, code: "75")],
               parent_antenne: regional_from_other_institution
      end
      let(:antenne) { national_antenne }

      before { described_class.new(antenne).call }

      it "cleans wrong parent for regional antennes" do
        expect(regional_with_wrong_parent.reload.parent_antenne).to eq(national_antenne)
      end
    end

    context 'with multiple institutions' do
      let(:other_institution) { create :institution }
      let!(:other_national) { create :antenne, :national, institution: other_institution }
      let!(:other_regional) { create :antenne, :regional, institution: other_institution, territorial_zones: [create(:territorial_zone, :region, code: "53")] }
      let!(:local_from_other) { create :antenne, :local, institution: other_institution, territorial_zones: [create(:territorial_zone, :departement, code: "22")] }
      let(:antenne) { regional_antenne }

      before { described_class.new(antenne).call }

      it "does not affect antennes from other institutions" do
        expect(local_from_other.reload.parent_antenne).to be_nil
      end
    end
  end
end
