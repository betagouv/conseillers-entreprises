require 'rails_helper'

describe CreateTerritorialCoverage do
  # ok : un ou plusieurs experts au niveau local couvrent tous les codes insee
  # ok : un ou plusieurs experts au niveau local avec des territoires spécifiques couvrent tous les codes insee
  # ko : pas d'experts sur ce sujet
  # ko : des experts au niveau local couvrent le sujet mais il manque des codes insee qui ne sont pas couverts
  # ko : des experts au niveau local avec des territoire spécifiques couvrent le sujet mais il manque des codes insee qui ne sont pas couverts
  # ko : des experts au niveau local sans territoire spécifique sont plusieurs à couvrir le même sujet
  # ko : des experts au niveau local avec des territoires spécifique sont plusieurs à couvrir le même sujet
  def create_communes
    beaufay = create(:territorial_zone, zone_type: :commune, code: '72026')
    bonnétable = create(:territorial_zone, zone_type: :commune, code: '72039')
    briosne = create(:territorial_zone, zone_type: :commune, code: '72048')
    jauzé = create(:territorial_zone, zone_type: :commune, code: '72148')
    [beaufay, bonnétable, briosne, jauzé]
  end

  def create_departements
    cantal = create(:territorial_zone, zone_type: :departement, code: '15')
    loire = create(:territorial_zone, zone_type: :departement, code: '42')
    rhone = create(:territorial_zone, zone_type: :departement, code: '69')
    haute_loire = create(:territorial_zone, zone_type: :departement, code: '43')
    [cantal, loire, rhone, haute_loire]
  end

  describe '#call' do
    let(:institution) { create(:institution) }
    let!(:national_antenne) { create(:antenne, :national, institution: institution) }
    let!(:institution_subject) { create(:institution_subject, institution: institution) }

    subject { described_class.new(institution_subject, grouped_experts).call }

    context "Territories with INSEE codes" do
      let!(:regional_antenne) { create(:antenne, :regional, institution: institution, parent_antenne: national_antenne, territorial_zones: create_communes) }
      let!(:local_antenne) { create(:antenne, :local, institution: institution, parent_antenne: regional_antenne, territorial_zones: create_communes) }
      let(:beaufay_insee_code) { '72026' }
      let(:bonnétable_insee_code) { '72039' }
      let(:briosne_insee_code) { '72048' }
      let(:jauzé_insee_code) { '72148' }

      context 'local coverage' do
        # ok : un ou plusieurs experts au niveau local couvrent tous les codes insee
        # ok : un ou plusieurs experts au niveau local avec des territoires spécifiques couvrent tous les codes insee
        # ko : pas d'experts sur ce sujet
        # ko : des experts au niveau local couvrent le sujet mais il manque des codes insee qui ne sont pas couverts
        # ko : des experts au niveau local avec des territoire spécifiques couvrent le sujet mais il manque des codes insee qui ne sont pas couverts
        # ko : des experts au niveau local sans territoire spécifique sont plusieurs à couvrir le même sujet
        # ko : des experts au niveau local avec des territoires spécifique sont plusieurs à couvrir le même sujet

        context 'un ou plusieurs experts au niveau local couvrent tous les codes insee' do
          let!(:local_expert) { create(:expert_with_users, antenne: local_antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let(:grouped_experts) { { local_antenne => { local_expert => local_expert.users } } }

          before { subject }

          it do
            expect(subject[:institution_subject_id]).to eq(institution_subject.id)
            expect(subject[:coverage]).to eq(:local)
            expect(subject[:anomalie]).to eq(:no_anomalie)
            expect(subject[:anomalie_details]).to be_nil
            expect(subject[:cooperations_details]).to be_nil
          end
        end

        context 'un ou plusieurs experts au niveau local avec des territoires spécifiques couvrent tous les codes insee' do
          let!(:local_expert) { create(:expert_with_users, antenne: local_antenne, territorial_zones: create_communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let(:grouped_experts) { { local_antenne => { local_expert => local_expert.users } } }

          before { subject }

          it do
            expect(subject[:institution_subject_id]).to eq(institution_subject.id)
            expect(subject[:coverage]).to eq(:local)
            expect(subject[:anomalie]).to eq(:no_anomalie)
            expect(subject[:anomalie_details]).to be_nil
          end
        end

        context 'pas d’experts sur ce sujet' do
          let(:grouped_experts) { { local_antenne => { [] => [] } } }

          before { subject }

          it do
            expect(subject[:institution_subject_id]).to eq(institution_subject.id)
            expect(subject[:coverage]).to be_nil
            expect(subject[:anomalie]).to eq(:no_expert)
            expect(subject[:anomalie_details]).to be_nil
          end
        end

        context 'pas d’utilisateurs sur ce sujet' do
          let!(:expert_without_users) { create(:expert, antenne: local_antenne, territorial_zones: create_communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let(:grouped_experts) { { local_antenne => { expert_without_users => [] } } }

          before { subject }

          it do
            expect(subject[:institution_subject_id]).to eq(institution_subject.id)
            expect(subject[:coverage]).to eq(:local)
            expect(subject[:anomalie]).to eq(:no_user)
            expect(subject[:anomalie_details][:experts]).to contain_exactly(expert_without_users)
          end
        end

        context 'des experts au niveau local couvrent le sujet mais il manque des codes insee qui ne sont pas couverts' do
          let!(:local_expert) { create(:expert_with_users, antenne: local_antenne, territorial_zones: [create(:territorial_zone, zone_type: :commune, code: bonnétable_insee_code)], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let(:grouped_experts) { { local_antenne => { local_expert => local_expert.users } } }

          before { subject }

          it do
            expect(subject[:institution_subject_id]).to eq(institution_subject.id)
            expect(subject[:coverage]).to eq(:local)
            expect(subject[:anomalie]).to eq(:missing_insee_codes)
            expect(subject[:anomalie_details][:missing_insee_codes].last[:zone_type]).to eq :communes
            expect(subject[:anomalie_details][:missing_insee_codes].last[:territories]).to eq [{ :code => "72026", :name => "Beaufay" }, { :code => "72048", :name => "Briosne-lès-Sables" }, { :code => "72148", :name => "Jauzé" }]

          end
        end

        context 'des experts au niveau local avec des territoire spécifiques couvrent le sujet mais il manque des codes insee qui ne sont pas couverts' do
          let!(:local_expert1) { create(:expert_with_users, antenne: local_antenne, territorial_zones: [create(:territorial_zone, zone_type: :commune, code: bonnétable_insee_code)], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let!(:local_expert2) { create(:expert_with_users, antenne: local_antenne, territorial_zones: [create(:territorial_zone, zone_type: :commune, code: beaufay_insee_code)], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let(:grouped_experts) { { local_antenne => { local_expert1 => local_expert1.users, local_expert2 => local_expert2.users } } }

          before { subject }

          it do
            expect(subject[:institution_subject_id]).to eq(institution_subject.id)
            expect(subject[:coverage]).to eq(:local)
            expect(subject[:anomalie]).to eq(:missing_insee_codes)
            expect(subject[:anomalie_details][:missing_insee_codes].last[:zone_type]).to eq :communes
            expect(subject[:anomalie_details][:missing_insee_codes].last[:territories]).to eq [{ :code => "72048", :name => "Briosne-lès-Sables" }, { :code => "72148", :name => "Jauzé" }]
          end
        end

        context 'des experts au niveau local sans territoire spécifique sont plusieurs à couvrir le même sujet' do
          let!(:local_expert1) { create(:expert_with_users, antenne: local_antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let!(:local_expert2) { create(:expert_with_users, antenne: local_antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let(:grouped_experts) { { local_antenne => { local_expert1 => local_expert1.users, local_expert2 => local_expert2.users } } }

          before { subject }

          it do
            expect(subject[:institution_subject_id]).to eq(institution_subject.id)
            expect(subject[:coverage]).to eq(:local)
            expect(subject[:anomalie]).to eq(:extra_insee_codes)
            expect(subject[:anomalie_details][:experts]).to contain_exactly(local_expert1.id, local_expert2.id)
            expect(subject[:anomalie_details][:extra_insee_codes].last[:zone_type]).to eq :communes
            expect(subject[:anomalie_details][:extra_insee_codes].last[:territories]).to eq [{ :code => "72026", :name => "Beaufay" }, { :code => "72039", :name => "Bonnétable" }, { :code => "72048", :name => "Briosne-lès-Sables" }, { :code => "72148", :name => "Jauzé" }]
          end
        end

        context 'des experts au niveau local avec des territoires spécifique sont plusieurs à couvrir le même sujet' do
          let!(:local_expert1) { create(:expert_with_users, antenne: local_antenne, territorial_zones: create_communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let!(:local_expert2) { create(:expert_with_users, antenne: local_antenne, territorial_zones: create_communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let(:grouped_experts) { { local_antenne => { local_expert1 => local_expert1.users, local_expert2 => local_expert2.users } } }

          before { subject }

          it do
            expect(subject[:institution_subject_id]).to eq(institution_subject.id)
            expect(subject[:coverage]).to eq(:local)
            expect(subject[:anomalie]).to eq(:extra_insee_codes)
            expect(subject[:anomalie_details][:experts]).to contain_exactly(local_expert1.id, local_expert2.id)
            expect(subject[:anomalie_details][:extra_insee_codes].last[:zone_type]).to eq :communes
            expect(subject[:anomalie_details][:extra_insee_codes].last[:territories]).to eq [{ :code => "72026", :name => "Beaufay" }, { :code => "72039", :name => "Bonnétable" }, { :code => "72048", :name => "Briosne-lès-Sables" }, { :code => "72148", :name => "Jauzé" }]
          end
        end
      end

      context 'regional coverage' do
        # ok : des experts au niveau régional couvrent tout le territoire
        # ok : des experts au niveau régional avec des territoires specifiques couvrent tout le territoire
        # ok : des experts au niveau régional et local avec des territoires spécifique couvrent tout le territoire
        # ko : des experts au niveau régional couvrent le sujet mais il manque des codes insee qui ne sont pas couverts
        # ko : des experts au niveau régional avec des territoires spécifiques couvrent le sujet mais il manque des codes insee qui ne sont pas couverts
        # ko : des experts au niveau local et régional avec des territoires spécifiques couvrent le sujet mais il manque des codes insee qui ne sont pas couverts
        # ko : des experts au niveau régional sont plusieurs à couvrir le même sujet
        # ko : des experts au niveau régional avec des territories spécifiques sont plusieurs à couvrir le même sujet
        # ko : des experts au niveau local et régional sont plusieurs à couvrir le même sujet
        # ko : des experts au niveau local et régional avec des territoires specifiques sont plusieurs à couvrir le même sujet

        context 'des experts au niveau régional couvrent tout le territoire' do
          let!(:regional_expert) { create(:expert_with_users, antenne: regional_antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let(:grouped_experts) { { regional_antenne => { regional_expert => regional_expert.users } } }

          before { subject }

          it do
            expect(subject[:institution_subject_id]).to eq(institution_subject.id)
            expect(subject[:coverage]).to eq(:regional)
            expect(subject[:anomalie]).to eq(:no_anomalie)
            expect(subject[:anomalie_details]).to be_nil
          end
        end

        context 'des experts au niveau régional avec des territoires specifiques couvrent tout le territoire' do
          let!(:regional_expert) { create(:expert_with_users, antenne: regional_antenne, territorial_zones: create_communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let(:grouped_experts) { { regional_antenne => { regional_expert => regional_expert.users } } }

          before { subject }

          it do
            expect(subject[:institution_subject_id]).to eq(institution_subject.id)
            expect(subject[:coverage]).to eq(:regional)
            expect(subject[:anomalie]).to eq(:no_anomalie)
            expect(subject[:anomalie_details]).to be_nil
          end
        end

        context 'des experts au niveau régional et local avec des territoires spécifique couvrent tout le territoire' do
          let(:tz1) { [create(:territorial_zone, zone_type: :commune, code: beaufay_insee_code), create(:territorial_zone, zone_type: :commune, code: bonnétable_insee_code)] }
          let(:tz2) { [create(:territorial_zone, zone_type: :commune, code: briosne_insee_code), create(:territorial_zone, zone_type: :commune, code: jauzé_insee_code)] }
          let!(:local_expert) { create(:expert_with_users, antenne: local_antenne, territorial_zones: tz1, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let!(:regional_expert) { create(:expert_with_users, antenne: regional_antenne, territorial_zones: tz2, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let(:grouped_experts) { { regional_antenne => { regional_expert => regional_expert.users }, local_antenne => { local_expert => local_expert.users } } }

          before { subject }

          it do
            expect(subject[:institution_subject_id]).to eq(institution_subject.id)
            expect(subject[:coverage]).to eq(:mixte)
            expect(subject[:anomalie]).to eq(:no_anomalie)
            expect(subject[:anomalie_details]).to be_nil
          end
        end

        context 'des experts au niveau régional couvrent le sujet mais il manque des codes insee qui ne sont pas couverts' do
          let(:tz) { [create(:territorial_zone, zone_type: :commune, code: bonnétable_insee_code), create(:territorial_zone, zone_type: :commune, code: jauzé_insee_code)] }
          let!(:regional_expert) { create(:expert_with_users, antenne: regional_antenne, territorial_zones: tz, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let(:grouped_experts) { { regional_antenne => { regional_expert => regional_expert.users } } }

          before { subject }

          it do
            expect(subject[:institution_subject_id]).to eq(institution_subject.id)
            expect(subject[:coverage]).to eq(:regional)
            expect(subject[:anomalie]).to eq(:missing_insee_codes)
            expect(subject[:anomalie_details][:missing_insee_codes].last[:zone_type]).to eq :communes
            expect(subject[:anomalie_details][:missing_insee_codes].last[:territories]).to eq [{ :code => "72026", :name => "Beaufay" }, { :code => "72048", :name => "Briosne-lès-Sables" }]
          end
        end

        context 'des experts au niveau régional avec des territoires spécifiques couvrent le sujet mais il manque des codes insee qui ne sont pas couverts' do
          let(:tz) { [create(:territorial_zone, zone_type: :commune, code: briosne_insee_code), create(:territorial_zone, zone_type: :commune, code: jauzé_insee_code)] }
          let!(:regional_expert) { create(:expert_with_users, antenne: regional_antenne, territorial_zones: tz, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let(:grouped_experts) { { regional_antenne => { regional_expert => regional_expert.users } } }

          before { subject }

          it do
            expect(subject[:institution_subject_id]).to eq(institution_subject.id)
            expect(subject[:coverage]).to eq(:regional)
            expect(subject[:anomalie]).to eq(:missing_insee_codes)
            expect(subject[:anomalie_details][:missing_insee_codes].last[:zone_type]).to eq :communes
            expect(subject[:anomalie_details][:missing_insee_codes].last[:territories]).to eq [{ :code => "72026", :name => "Beaufay" }, { :code => "72039", :name => "Bonnétable" }]
          end
        end

        context 'des experts au niveau local et régional avec des territoires spécifiques couvrent le sujet mais il manque des codes insee qui ne sont pas couverts' do
          let!(:local_expert) { create(:expert_with_users, antenne: regional_antenne, territorial_zones: [create(:territorial_zone, zone_type: :commune, code: jauzé_insee_code)], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let!(:regional_expert) { create(:expert_with_users, antenne: regional_antenne, territorial_zones: [create(:territorial_zone, zone_type: :commune, code: briosne_insee_code)], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let(:grouped_experts) { { regional_antenne => { regional_expert => regional_expert.users } } }

          before { subject }

          it do
            expect(subject[:institution_subject_id]).to eq(institution_subject.id)
            # TODO : coverage mixte ?
            expect(subject[:coverage]).to eq(:regional)
            expect(subject[:anomalie]).to eq(:missing_insee_codes)
            expect(subject[:anomalie_details][:missing_insee_codes].last[:zone_type]).to eq :communes
            expect(subject[:anomalie_details][:missing_insee_codes].last[:territories]).to eq [{ :code => "72026", :name => "Beaufay" }, { :code => "72039", :name => "Bonnétable" }]
          end
        end

        context 'des experts au niveau régional sont plusieurs à couvrir le même sujet' do
          let!(:regional_expert1) { create(:expert_with_users, antenne: regional_antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let!(:regional_expert2) { create(:expert_with_users, antenne: regional_antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let(:grouped_experts) { { regional_antenne => { regional_expert1 => regional_expert1.users, regional_expert2 => regional_expert2.users } } }

          before { subject }

          it do
            expect(subject[:institution_subject_id]).to eq(institution_subject.id)
            expect(subject[:coverage]).to eq(:regional)
            expect(subject[:anomalie]).to eq(:extra_insee_codes)
            expect(subject[:anomalie_details][:experts]).to contain_exactly(regional_expert1.id, regional_expert2.id)
            expect(subject[:anomalie_details][:extra_insee_codes].last[:zone_type]).to eq :communes
            expect(subject[:anomalie_details][:extra_insee_codes].last[:territories]).to eq [{ :code => "72026", :name => "Beaufay" }, { :code => "72039", :name => "Bonnétable" }, { :code => "72048", :name => "Briosne-lès-Sables" }, { :code => "72148", :name => "Jauzé" }]
          end
        end

        context 'des experts au niveau régional avec des territories spécifiques sont plusieurs à couvrir le même sujet' do
          let!(:regional_expert1) { create(:expert_with_users, antenne: regional_antenne, territorial_zones: create_communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let!(:regional_expert2) { create(:expert_with_users, antenne: regional_antenne, territorial_zones: create_communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let(:grouped_experts) { { regional_antenne => { regional_expert1 => regional_expert1.users, regional_expert2 => regional_expert2.users } } }

          before { subject }

          it do
            expect(subject[:institution_subject_id]).to eq(institution_subject.id)
            expect(subject[:coverage]).to eq(:regional)
            expect(subject[:anomalie]).to eq(:extra_insee_codes)
            expect(subject[:anomalie_details][:experts]).to contain_exactly(regional_expert1.id, regional_expert2.id)
            expect(subject[:anomalie_details][:extra_insee_codes].last[:zone_type]).to eq :communes
            expect(subject[:anomalie_details][:extra_insee_codes].last[:territories]).to eq [{ :code => "72026", :name => "Beaufay" }, { :code => "72039", :name => "Bonnétable" }, { :code => "72048", :name => "Briosne-lès-Sables" }, { :code => "72148", :name => "Jauzé" }]
          end
        end

        context 'des experts au niveau local et régional sont plusieurs à couvrir le même sujet' do
          let!(:local_expert) { create(:expert_with_users, antenne: local_antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let!(:regional_expert) { create(:expert_with_users, antenne: regional_antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let(:grouped_experts) { { regional_antenne => { local_expert => local_expert.users, regional_expert => regional_expert.users } } }

          before { subject }

          it do
            expect(subject[:institution_subject_id]).to eq(institution_subject.id)
            expect(subject[:coverage]).to eq(:mixte)
            expect(subject[:anomalie]).to eq(:extra_insee_codes)
            expect(subject[:anomalie_details][:experts]).to contain_exactly(local_expert.id, regional_expert.id)
            expect(subject[:anomalie_details][:extra_insee_codes].last[:zone_type]).to eq :communes
            expect(subject[:anomalie_details][:extra_insee_codes].last[:territories]).to eq [{ :code => "72026", :name => "Beaufay" }, { :code => "72039", :name => "Bonnétable" }, { :code => "72048", :name => "Briosne-lès-Sables" }, { :code => "72148", :name => "Jauzé" }]
          end
        end

        context 'des experts au niveau local et régional avec des territoires specifiques sont plusieurs à couvrir le même sujet' do
          let!(:local_expert) { create(:expert_with_users, antenne: local_antenne, territorial_zones: create_communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let!(:regional_expert) { create(:expert_with_users, antenne: regional_antenne, territorial_zones: create_communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let(:grouped_experts) { { regional_antenne => { local_expert => local_expert.users, regional_expert => regional_expert.users } } }

          before { subject }

          it do
            expect(subject[:institution_subject_id]).to eq(institution_subject.id)
            expect(subject[:coverage]).to eq(:mixte)
            expect(subject[:anomalie]).to eq(:extra_insee_codes)
            expect(subject[:anomalie_details][:experts]).to contain_exactly(local_expert.id, regional_expert.id)
            expect(subject[:anomalie_details][:extra_insee_codes].last[:zone_type]).to eq :communes
            expect(subject[:anomalie_details][:extra_insee_codes].last[:territories]).to eq [{ :code => "72026", :name => "Beaufay" }, { :code => "72039", :name => "Bonnétable" }, { :code => "72048", :name => "Briosne-lès-Sables" }, { :code => "72148", :name => "Jauzé" }]
          end
        end

        context 'pas d’utilisateurs sur ce sujet' do
          let!(:expert_without_users) { create(:expert, antenne: regional_antenne, territorial_zones: create_communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
          let(:grouped_experts) { { regional_antenne => { expert_without_users => expert_without_users.users } } }

          before { subject }

          it do
            expect(subject[:institution_subject_id]).to eq(institution_subject.id)
            expect(subject[:coverage]).to eq(:regional)
            expect(subject[:anomalie]).to eq(:no_user)
            expect(subject[:anomalie_details][:experts]).to contain_exactly(expert_without_users)
          end
        end
      end
    end

    context "Territories with departments" do
      let!(:regional_antenne) { create(:antenne, :regional, institution: institution, parent_antenne: national_antenne, territorial_zones: create_departements) }
      let!(:local_antenne) { create(:antenne, :local, institution: institution, parent_antenne: regional_antenne, territorial_zones: create_departements) }
      let(:cantal_code) { '15' }
      let(:loire_code) { '42' }
      let(:rhone_code) { '69' }
      let(:haute_loire_code) { '43' }

      context 'un ou plusieurs experts au niveau local avec des territoires spécifiques couvrent tous les départements' do
        let!(:local_expert) { create(:expert_with_users, antenne: local_antenne, territorial_zones: create_departements, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
        let(:grouped_experts) { { local_antenne => { local_expert => local_expert.users } } }

        before { subject }

        it do
          expect(subject[:institution_subject_id]).to eq(institution_subject.id)
          expect(subject[:coverage]).to eq(:local)
          expect(subject[:anomalie]).to eq(:no_anomalie)
          expect(subject[:anomalie_details]).to be_nil
        end
      end

      context 'un ou plusieurs experts de plusieurs antennes au niveau local avec des territoires spécifiques couvrent tous les départements' do
        # Antenne 1 avec deux départements(15 et 42) que deux experts se repartissent
        # Antenne 2 avec deux départements(69 et 43) et un seul expert
        let(:departments1) { [create(:territorial_zone, zone_type: :departement, code: cantal_code), create(:territorial_zone, zone_type: :departement, code: loire_code)] }
        let(:departments2) { [create(:territorial_zone, zone_type: :departement, code: rhone_code), create(:territorial_zone, zone_type: :departement, code: haute_loire_code)] }
        let!(:local_antenne1) { create(:antenne, :local, institution: institution, parent_antenne: regional_antenne, territorial_zones: departments1) }
        let!(:local_antenne2) { create(:antenne, :local, institution: institution, parent_antenne: regional_antenne, territorial_zones: departments2) }

        let!(:local_expert1_1) { create(:expert_with_users, antenne: local_antenne1, territorial_zones: [create(:territorial_zone, zone_type: :departement, code: cantal_code)], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
        let!(:local_expert1_2) { create(:expert_with_users, antenne: local_antenne1, territorial_zones: [create(:territorial_zone, zone_type: :departement, code: loire_code)], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
        let!(:local_expert2) { create(:expert_with_users, antenne: local_antenne2, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
        let(:grouped_experts) { { local_antenne1 => { local_expert1_1 => local_expert1_1.users, local_expert1_2 => local_expert1_2.users }, local_antenne2 => { local_expert2 => local_expert2.users } } }

        before { subject }

        it do
          expect(subject[:institution_subject_id]).to eq(institution_subject.id)
          expect(subject[:coverage]).to eq(:local)
          expect(subject[:anomalie]).to eq(:no_anomalie)
          expect(subject[:anomalie_details]).to be_nil
        end
      end

      context 'des experts au niveau local avec des territoire spécifiques couvrent le sujet mais il manque des départements qui ne sont pas couverts' do
        let!(:local_expert1) { create(:expert_with_users, antenne: local_antenne, territorial_zones: [create(:territorial_zone, zone_type: :departement, code: cantal_code)], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
        let!(:local_expert2) { create(:expert_with_users, antenne: local_antenne, territorial_zones: [create(:territorial_zone, zone_type: :departement, code: loire_code)], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
        let(:grouped_experts) { { local_antenne => { local_expert1 => local_expert1.users, local_expert2 => local_expert2.users } } }

        before { subject }

        it do
          expect(subject[:institution_subject_id]).to eq(institution_subject.id)
          expect(subject[:coverage]).to eq(:local)
          expect(subject[:anomalie]).to eq(:missing_insee_codes)
          expect(subject[:anomalie_details][:missing_insee_codes]).to eq [{ :zone_type => :regions, :territories => [] }, { :zone_type => :departements, :territories => [{ :code => "69", :name => "Rhône" }, { :code => "43", :name => "Haute-Loire" }] }, { :zone_type => :epcis, :territories => [] }, { :zone_type => :communes, :territories => [] }]
        end
      end

      context 'des experts au niveau local avec des territoires spécifique sont plusieurs à couvrir le même sujet' do
        let!(:local_expert1) { create(:expert_with_users, antenne: local_antenne, territorial_zones: [create(:territorial_zone, zone_type: :departement, code: cantal_code), create(:territorial_zone, zone_type: :departement, code: loire_code)], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
        let!(:local_expert2) { create(:expert_with_users, antenne: local_antenne, territorial_zones: [create(:territorial_zone, zone_type: :departement, code: loire_code), create(:territorial_zone, zone_type: :departement, code: rhone_code)], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
        let!(:local_expert3) { create(:expert_with_users, antenne: local_antenne, territorial_zones: [create(:territorial_zone, zone_type: :departement, code: haute_loire_code)], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
        let(:grouped_experts) { { local_antenne => { local_expert1 => local_expert1.users, local_expert2 => local_expert2.users, local_expert3 => local_expert3.users } } }

        before { subject }

        it do
          expect(subject[:institution_subject_id]).to eq(institution_subject.id)
          expect(subject[:coverage]).to eq(:local)
          expect(subject[:anomalie]).to eq(:extra_insee_codes)
          expect(subject[:anomalie_details][:experts]).to contain_exactly(local_expert1.id, local_expert2.id)
          expect(subject[:anomalie_details][:extra_insee_codes]).to eq [{ :zone_type => :regions, :territories => [] }, { :zone_type => :departements, :territories => [{ :code => "42", :name => "Loire" }] }, { :zone_type => :epcis, :territories => [] }, { :zone_type => :communes, :territories => [] }]
        end
      end
    end

    describe 'themes with territories and cooperation' do
      let!(:regional_antenne) { create(:antenne, :regional, institution: institution, parent_antenne: national_antenne, territorial_zones: [create(:territorial_zone, zone_type: :region, code: "53")]) }
      let(:cooperation) { create(:cooperation, institution: institution) }
      let(:landing) { create(:landing, cooperation: cooperation) }
      let!(:landing_theme) { create(:landing_theme, landings: [landing], subjects: [a_subject]) }
      let!(:cooperation_theme) { create(:cooperation_theme, cooperation: cooperation, theme: a_theme) }
      let(:a_theme) { create(:theme, territorial_zones: [create(:territorial_zone, zone_type: :departement, code: '22')]) }
      let(:a_subject) { create(:subject, theme: a_theme) }
      let(:institution_subject) { create(:institution_subject, subject: a_subject, institution: institution) }

      describe 'Une antenne dans la région avec des trou de référencement sur ce sujet apparait comme non couverte' do
        let!(:expert_without_users) { create(:expert, antenne: regional_antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
        let(:grouped_experts) { { regional_antenne => { expert_without_users => expert_without_users.users } } }

        before { subject }

        it do
          expect(subject[:institution_subject_id]).to eq(institution_subject.id)
          expect(subject[:coverage]).to eq(:regional)
          expect(subject[:anomalie]).to eq(:no_user)
          expect(subject[:cooperations_details][:cooperations]).to eq [{ :id => cooperation.id, :name => cooperation.name }]
          expect(subject[:cooperations_details][:theme_territories]).to eq [{ :territories => [], :zone_type => :regions }, { :territories => [{ :code => "22", :name => "Côtes-d'Armor" }], :zone_type => :departements }, { :territories => [], :zone_type => :epcis }, { :territories => [], :zone_type => :communes }]
        end
      end

      describe 'Une antenne hors territoire n’apparait pas dans comme anomalie' do
        let!(:out_of_region_antenne) { create(:antenne, :local, institution: institution, territorial_zones: [create(:territorial_zone, zone_type: :departement, code: '42')]) }
        let!(:expert_without_users) { create(:expert, antenne: out_of_region_antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
        let(:grouped_experts) { { out_of_region_antenne => { expert_without_users => expert_without_users.users } } }

        before { subject }

        it do
          expect(subject[:institution_subject_id]).to eq(institution_subject.id)
          expect(subject[:coverage]).to eq(:local)
          expect(subject[:anomalie]).to eq(:no_anomalie)
          expect(subject[:cooperations_details][:cooperations]).to eq [{ :id => cooperation.id, :name => cooperation.name }]
          expect(subject[:cooperations_details][:theme_territories]).to eq [{ :territories => [], :zone_type => :regions }, { :territories => [{ :code => "22", :name => "Côtes-d'Armor" }], :zone_type => :departements }, { :territories => [], :zone_type => :epcis }, { :territories => [], :zone_type => :communes }]
        end
      end
    end

    context "Expert with global coverage" do
      let!(:global_expert) { create(:expert_with_users, antenne: national_antenne, is_global_zone: true, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
      let(:grouped_experts) { { national_antenne => { global_expert => global_expert.users } } }
      let(:experts_ids) { global_expert.id }

      before { subject }

      it do
        expect(subject[:institution_subject_id]).to eq(institution_subject.id)
        expect(subject[:coverage]).to eq(:national)
        expect(subject[:anomalie]).to eq(:no_anomalie)
        expect(subject[:anomalie_details]).to be_nil
      end
    end
  end

  describe "#get_coverage" do
    let(:institution) { create(:institution) }
    let!(:institution_subject) { create(:institution_subject, institution: institution) }
    let!(:national_antenne) { create(:antenne, :national, institution: institution) }
    let!(:regional_antenne) { create(:antenne, :regional, institution: institution, parent_antenne: national_antenne, territorial_zones: create_communes) }
    let!(:local_antenne) { create(:antenne, :local, institution: institution, parent_antenne: regional_antenne, territorial_zones: create_communes) }

    before do
      national_antenne.reload
      regional_antenne.reload
      local_antenne.reload
    end

    subject { described_class.new(institution_subject, grouped_experts).send(:get_coverage) }

    context "local coverage" do
      let!(:local_expert) { create(:expert_with_users, antenne: local_antenne, territorial_zones: create_communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }

      context "with one antenne" do
        let(:grouped_experts) { { local_antenne => { local_expert => local_expert.users } } }

        before { subject }

        it do
          is_expected.to eq(:local)
        end
      end

      describe "with two antennes and a regional antennes with only manager" do
        let(:grouped_experts) { { local_antenne => { local_expert => local_expert.users }, regional_antenne => { Expert.new => [create(:user, :manager, antenne: regional_antenne)] } } }

        before { subject }

        it do
          is_expected.to eq(:local)
        end
      end
    end

    context "regional coverage" do
      let!(:regional_expert) { create(:expert_with_users, antenne: regional_antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }

      context "with one antenne" do
        let(:grouped_experts) { { regional_antenne => { regional_expert => regional_expert.users } } }
        let(:experts) { [regional_expert] }

        before { subject }

        it do
          is_expected.to eq(:regional)
        end

      end

      context "with two antennes and a national antenne with only manager" do
        let(:grouped_experts) { { regional_antenne => { regional_expert => regional_expert.users }, national_antenne => { Expert.new => [create(:user, :manager, antenne: national_antenne)] } } }
        let(:experts) { [regional_expert] }

        before { subject }

        it do
          is_expected.to eq(:regional)
        end
      end
    end

    context "mixte coverage" do
      let!(:local_expert) { create(:expert_with_users, antenne: local_antenne, territorial_zones: create_communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
      let!(:regional_expert) { create(:expert_with_users, antenne: regional_antenne, territorial_zones: create_communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
      let(:grouped_experts) { { local_antenne => { local_expert => local_expert.users }, regional_antenne => { regional_expert => regional_expert.users } } }
      let(:experts) { [local_expert, regional_expert] }

      before { subject }

      it do
        is_expected.to eq(:mixte)
      end
    end
  end

  describe "#get_match_filters" do
    let(:institution) { create(:institution) }
    let!(:institution_subject) { create(:institution_subject, institution: institution) }
    let!(:antenne) { create(:antenne, :local, institution: institution, territorial_zones: create_communes) }

    before do
      antenne.reload
    end

    subject { described_class.new(institution_subject, grouped_experts).send(:get_match_filters) }

    context "Only antennes match filters" do
      let!(:antenne_match_filter) { create :match_filter, antenne: antenne, min_years_of_existence: 1 }
      let(:expert) { create(:expert_with_users, antenne: antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
      let(:grouped_experts) { { antenne => { expert.id => expert.users } } }

      before { subject }

      it do
        is_expected.to eq({ :antenne => ["ancienneté minimum (en année) - #{antenne.name}"],
                            :expert => [],
                            :institution => [] })
      end
    end
  end
end
