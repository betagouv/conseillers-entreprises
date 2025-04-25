require 'rails_helper'

describe CoverageService do
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

  describe '#call' do
    let(:institution) { create(:institution) }
    let!(:national_antenne) { create(:antenne, :national, institution: institution) }
    let!(:regional_antenne) { create(:antenne, :regional, institution: institution, parent_antenne: national_antenne, territorial_zones: create_communes) }
    let!(:local_antenne) { create(:antenne, :local, institution: institution, parent_antenne: regional_antenne, territorial_zones: create_communes) }
    let!(:region) { create(:territorial_zone, zone_type: :region, code: '52') }
    let!(:institution_subject) { create(:institution_subject, institution: institution) }
    let(:beaufay_insee_code) { '72026' }
    let(:bonnétable_insee_code) { '72039' }
    let(:briosne_insee_code) { '72048' }
    let(:jauzé_insee_code) { '72148' }

    before do
      national_antenne.reload
      regional_antenne.reload
      local_antenne.reload
    end

    subject { described_class.new(institution_subject, grouped_experts).call }

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
          expect(subject[:anomalie_details][:experts]).to contain_exactly(expert_without_users.id)
        end
      end

      context 'des experts au niveau local couvrent le sujet mais il manque des codes insee qui ne sont pas couverts' do
        let!(:local_expert) { create(:expert_with_users, antenne: local_antenne, territorial_zones: [create(:territorial_zone, zone_type: :commune, code: bonnétable_insee_code)], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
        let(:grouped_experts) { { local_antenne => { local_expert => local_expert.users } } }

        before { subject }

        # TODO ajouter un test qui affiche d'autres territoires manquants que des codes insee
        #
        it do
          expect(subject[:institution_subject_id]).to eq(institution_subject.id)
          expect(subject[:coverage]).to eq(:local)
          expect(subject[:anomalie]).to eq(:missing_insee_codes)
          expect(subject[:anomalie_details][:missing_insee_codes]).to contain_exactly(briosne_insee_code, jauzé_insee_code, beaufay_insee_code)
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
          expect(subject[:anomalie_details][:missing_insee_codes]).to contain_exactly(briosne_insee_code, jauzé_insee_code)
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
          expect(subject[:anomalie_details][:extra_insee_codes]).to contain_exactly(bonnétable_insee_code, beaufay_insee_code, jauzé_insee_code, briosne_insee_code)
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
          expect(subject[:anomalie_details][:extra_insee_codes]).to contain_exactly(bonnétable_insee_code, beaufay_insee_code, jauzé_insee_code, briosne_insee_code)
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
        let!(:local_expert) { create(:expert_with_users, antenne: regional_antenne, territorial_zones: tz1, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
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
          expect(subject[:anomalie_details][:missing_insee_codes]).to contain_exactly(briosne_insee_code, beaufay_insee_code)
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
          expect(subject[:anomalie_details][:missing_insee_codes]).to contain_exactly(bonnétable_insee_code, beaufay_insee_code)
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
          expect(subject[:anomalie_details][:missing_insee_codes]).to contain_exactly(bonnétable_insee_code, beaufay_insee_code)
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
          expect(subject[:anomalie_details][:extra_insee_codes]).to contain_exactly(bonnétable_insee_code, beaufay_insee_code, jauzé_insee_code, briosne_insee_code)
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
          expect(subject[:anomalie_details][:extra_insee_codes]).to contain_exactly(bonnétable_insee_code, beaufay_insee_code, jauzé_insee_code, briosne_insee_code)
        end
      end

      context 'des experts au niveau local et régional sont plusieurs à couvrir le même sujet' do
        let!(:local_expert) { create(:expert_with_users, antenne: local_antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
        let!(:regional_expert) { create(:expert_with_users, antenne: regional_antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
        let(:grouped_experts) { { regional_antenne => { local_expert => local_expert.users, regional_expert => regional_expert.users } } }

        before { subject }

        it do
          expect(subject[:institution_subject_id]).to eq(institution_subject.id)
          # TODO : coverage mixte ?
          expect(subject[:coverage]).to eq(:regional)
          expect(subject[:anomalie]).to eq(:extra_insee_codes)
          expect(subject[:anomalie_details][:experts]).to contain_exactly(local_expert.id, regional_expert.id)
          expect(subject[:anomalie_details][:extra_insee_codes]).to contain_exactly(bonnétable_insee_code, beaufay_insee_code, jauzé_insee_code, briosne_insee_code)
        end
      end

      context 'des experts au niveau local et régional avec des territoires specifiques sont plusieurs à couvrir le même sujet' do
        let!(:local_expert) { create(:expert_with_users, antenne: local_antenne, territorial_zones: create_communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
        let!(:regional_expert) { create(:expert_with_users, antenne: regional_antenne, territorial_zones: create_communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
        let(:grouped_experts) { { regional_antenne => { local_expert => local_expert.users, regional_expert => regional_expert.users } } }

        before { subject }

        it do
          expect(subject[:institution_subject_id]).to eq(institution_subject.id)
          # TODO : coverage mixte ?
          expect(subject[:coverage]).to eq(:regional)
          expect(subject[:anomalie]).to eq(:extra_insee_codes)
          expect(subject[:anomalie_details][:experts]).to contain_exactly(local_expert.id, regional_expert.id)
          expect(subject[:anomalie_details][:extra_insee_codes]).to contain_exactly(bonnétable_insee_code, beaufay_insee_code, jauzé_insee_code, briosne_insee_code)
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
          expect(subject[:anomalie_details][:experts]).to contain_exactly(expert_without_users.id)
        end
      end
    end

    context 'themes with territories' do
      let(:a_theme) { create(:theme, territories: [region]) }
      let(:a_subject) { create(:subject, theme: a_theme) }
      let(:institution_subject) { create(:institution_subject, subject: a_subject, institution: institution) }

      describe 'Une antenne dans la région avec des trou de référencement sur ce sujet apparait comme non couverte' do
        let!(:expert_without_users) { create(:expert, antenne: local_antenne, territorial_zones: create_communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
        let(:grouped_experts) { { regional_antenne => { expert_without_users => expert_without_users.users } } }

        before { subject }

        it do
          expect(subject[:institution_subject_id]).to eq(institution_subject.id)
          expect(subject[:coverage]).to eq(:local)
          expect(subject[:anomalie]).to eq(:no_user)
        end
      end

      describe 'Une antenne hors région n’apparait pas dans comme anomalie' do
        let!(:out_of_region_antenne) { create(:antenne, :local, institution: institution, communes: [create(:commune)]) }
        let!(:expert_without_users) { create(:expert, antenne: out_of_region_antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }

        before { described_class.perform_sync(out_of_region_antenne.id) }

        it do
          expect(out_of_region_antenne.referencement_coverages.count).to eq(1)
          expect(out_of_region_antenne.referencement_coverages.first.antenne).to eq(out_of_region_antenne)
          expect(out_of_region_antenne.referencement_coverages.first.anomalie).to eq('no_anomalie')
          expect(out_of_region_antenne.referencement_coverages.first.coverage).to eq('local')
          expect(out_of_region_antenne.referencement_coverages.first.anomalie_details).to be_nil
        end
      end
    end
  end
end
