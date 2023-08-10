# frozen_string_literal: true

require 'rails_helper'
describe UpdateAntenneCoverage do
  let(:institution) { create(:institution) }
  let!(:local_antenne) { create(:antenne, :local, institution: institution, communes: communes) }
  let!(:regional_antenne) { create(:antenne, :regional, institution: institution, communes: communes) }
  let!(:national_antenne) { create(:antenne, :national, institution: institution) }
  let(:beaufay) { create(:commune, insee_code: '72026') }
  let(:bonnétable) { create(:commune, insee_code: '72039') }
  let(:briosne) { create(:commune, insee_code: '72048') }
  let(:jauzé) { create(:commune, insee_code: '72148') }
  let(:communes) { [beaufay, bonnétable, briosne, jauzé] }
  let!(:region) { create(:territory, :region, communes: communes, code_region: 52) }
  let!(:institution_subject) { create(:institution_subject, institution: institution) }

  before do
    national_antenne.reload
    regional_antenne.reload
    local_antenne.reload
  end

  subject { described_class.new(local_antenne) }

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

      before { subject.call }

      it do
        expect(local_antenne.referencement_coverages.count).to eq(1)
        expect(local_antenne.referencement_coverages.first.antenne).to eq(local_antenne)
        expect(local_antenne.referencement_coverages.first.anomalie).to eq('no_anomalie')
        expect(local_antenne.referencement_coverages.first.coverage).to eq('local')
        expect(local_antenne.referencement_coverages.first.anomalie_details).to be_nil
      end
    end

    context 'un ou plusieurs experts au niveau local avec des territoires spécifiques couvrent tous les codes insee' do
      let!(:local_expert) { create(:expert_with_users, antenne: local_antenne, communes: communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }

      before { subject.call }

      it do
        expect(local_antenne.referencement_coverages.first.anomalie).to eq('no_anomalie')
        expect(local_antenne.referencement_coverages.first.coverage).to eq('local')
        expect(local_antenne.referencement_coverages.first.anomalie_details).to be_nil
      end
    end

    context 'pas d’experts sur ce sujet' do
      before { subject.call }

      it do
        expect(local_antenne.referencement_coverages.first.anomalie).to eq('no_expert')
        expect(local_antenne.referencement_coverages.first.coverage).to be_nil
        expect(local_antenne.referencement_coverages.first.anomalie_details).to be_nil
      end
    end

    context 'pas d’utilisateurs sur ce sujet' do
      let!(:expert_without_users) { create(:expert, antenne: local_antenne, communes: communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }

      before { subject.call }

      it do
        expect(local_antenne.referencement_coverages.first.anomalie).to eq('no_user')
        expect(local_antenne.referencement_coverages.first.coverage).to eq('local')
        expect(local_antenne.referencement_coverages.first.anomalie_details['experts']).to contain_exactly(expert_without_users.id)
      end
    end

    context 'des experts au niveau local couvrent le sujet mais il manque des codes insee qui ne sont pas couverts' do
      let!(:local_expert) { create(:expert_with_users, antenne: local_antenne, communes: [bonnétable], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }

      before { subject.call }

      it do
        expect(local_antenne.referencement_coverages.first.anomalie).to eq('missing_insee_codes')
        expect(local_antenne.referencement_coverages.first.coverage).to eq('local')
        expect(local_antenne.referencement_coverages.first.anomalie_details['missing_insee_codes']).to contain_exactly("#{beaufay.insee_code}", "#{briosne.insee_code}", "#{jauzé.insee_code}")
      end
    end

    context 'des experts au niveau local avec des territoire spécifiques couvrent le sujet mais il manque des codes insee qui ne sont pas couverts' do
      let!(:local_expert1) { create(:expert_with_users, antenne: local_antenne, communes: [bonnétable], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
      let!(:local_expert2) { create(:expert_with_users, antenne: local_antenne, communes: [beaufay], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }

      before { subject.call }

      it do
        expect(local_antenne.referencement_coverages.first.anomalie).to eq('missing_insee_codes')
        expect(local_antenne.referencement_coverages.first.coverage).to eq('local')
        expect(local_antenne.referencement_coverages.first.anomalie_details['missing_insee_codes']).to contain_exactly("#{briosne.insee_code}", "#{jauzé.insee_code}")
      end
    end

    context 'des experts au niveau local sans territoire spécifique sont plusieurs à couvrir le même sujet' do
      let!(:local_expert1) { create(:expert_with_users, antenne: local_antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
      let!(:local_expert2) { create(:expert_with_users, antenne: local_antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }

      before { subject.call }

      it do
        expect(local_antenne.referencement_coverages.first.anomalie).to eq('extra_insee_codes')
        expect(local_antenne.referencement_coverages.first.coverage).to eq('local')
        expect(local_antenne.referencement_coverages.first.anomalie_details['experts']).to contain_exactly(local_expert1.id, local_expert2.id)
        expect(local_antenne.referencement_coverages.first.anomalie_details['extra_insee_codes']).to contain_exactly("#{bonnétable.insee_code}", "#{beaufay.insee_code}", "#{jauzé.insee_code}", "#{briosne.insee_code}")
      end
    end

    context 'des experts au niveau local avec des territoires spécifique sont plusieurs à couvrir le même sujet' do
      let!(:local_expert1) { create(:expert_with_users, antenne: local_antenne, communes: communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
      let!(:local_expert2) { create(:expert_with_users, antenne: local_antenne, communes: communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }

      before { subject.call }

      it do
        expect(local_antenne.referencement_coverages.first.anomalie).to eq('extra_insee_codes')
        expect(local_antenne.referencement_coverages.first.coverage).to eq('local')
        expect(local_antenne.referencement_coverages.first.anomalie_details['experts']).to contain_exactly(local_expert1.id, local_expert2.id)
        expect(local_antenne.referencement_coverages.first.anomalie_details['extra_insee_codes']).to contain_exactly("#{bonnétable.insee_code}", "#{beaufay.insee_code}", "#{jauzé.insee_code}", "#{briosne.insee_code}")
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

      before { subject.call }

      it do
        expect(local_antenne.referencement_coverages.count).to eq(1)
        expect(local_antenne.referencement_coverages.first.antenne).to eq(local_antenne)
        expect(local_antenne.referencement_coverages.first.anomalie).to eq('no_anomalie')
        expect(local_antenne.referencement_coverages.first.coverage).to eq('regional')
        expect(local_antenne.referencement_coverages.first.anomalie_details).to be_nil
      end
    end

    context 'des experts au niveau régional avec des territoires specifiques couvrent tout le territoire' do
      let!(:regional_expert) { create(:expert_with_users, antenne: regional_antenne, communes: communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }

      before { subject.call }

      it do
        expect(local_antenne.referencement_coverages.first.anomalie).to eq('no_anomalie')
        expect(local_antenne.referencement_coverages.first.coverage).to eq('regional')
        expect(local_antenne.referencement_coverages.first.anomalie_details).to be_nil
      end
    end

    context 'des experts au niveau régional et local avec des territoires spécifique couvrent tout le territoire' do
      let!(:local_expert) { create(:expert_with_users, antenne: regional_antenne, communes: [beaufay, bonnétable], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
      let!(:regional_expert) { create(:expert_with_users, antenne: regional_antenne, communes: [briosne, jauzé], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }

      before { subject.call }

      it do
        expect(local_antenne.referencement_coverages.first.anomalie).to eq('no_anomalie')
        expect(local_antenne.referencement_coverages.first.coverage).to eq('regional')
        expect(local_antenne.referencement_coverages.first.anomalie_details).to be_nil
      end
    end

    context 'des experts au niveau régional couvrent le sujet mais il manque des codes insee qui ne sont pas couverts' do
      let!(:regional_expert) { create(:expert_with_users, antenne: regional_antenne, communes: [bonnétable, jauzé], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }

      before { subject.call }

      it do
        expect(local_antenne.referencement_coverages.first.anomalie).to eq('missing_insee_codes')
        expect(local_antenne.referencement_coverages.first.coverage).to eq('regional')
        expect(local_antenne.referencement_coverages.first.anomalie_details['missing_insee_codes']).to contain_exactly("#{beaufay.insee_code}", "#{briosne.insee_code}")
      end
    end

    context 'des experts au niveau régional avec des territoires spécifiques couvrent le sujet mais il manque des codes insee qui ne sont pas couverts' do
      let!(:regional_expert) { create(:expert_with_users, antenne: regional_antenne, communes: [briosne, jauzé], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }

      before { subject.call }

      it do
        expect(local_antenne.referencement_coverages.first.anomalie).to eq('missing_insee_codes')
        expect(local_antenne.referencement_coverages.first.coverage).to eq('regional')
        expect(local_antenne.referencement_coverages.first.anomalie_details['missing_insee_codes']).to contain_exactly("#{beaufay.insee_code}", "#{bonnétable.insee_code}")
      end
    end

    context 'des experts au niveau local et régional avec des territoires spécifiques couvrent le sujet mais il manque des codes insee qui ne sont pas couverts' do
      let!(:local_expert) { create(:expert_with_users, antenne: regional_antenne, communes: [jauzé], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
      let!(:regional_expert) { create(:expert_with_users, antenne: regional_antenne, communes: [briosne], experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }

      before { subject.call }

      it do
        expect(local_antenne.referencement_coverages.first.anomalie).to eq('missing_insee_codes')
        expect(local_antenne.referencement_coverages.first.coverage).to eq('regional')
        expect(local_antenne.referencement_coverages.first.anomalie_details['missing_insee_codes']).to contain_exactly("#{beaufay.insee_code}", "#{bonnétable.insee_code}")
      end
    end

    context 'des experts au niveau régional sont plusieurs à couvrir le même sujet' do
      let!(:regional_expert1) { create(:expert_with_users, antenne: regional_antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
      let!(:regional_expert2) { create(:expert_with_users, antenne: regional_antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }

      before { subject.call }

      it do
        expect(local_antenne.referencement_coverages.first.anomalie).to eq('extra_insee_codes')
        expect(local_antenne.referencement_coverages.first.coverage).to eq('regional')
        expect(local_antenne.referencement_coverages.first.anomalie_details['experts']).to contain_exactly(regional_expert1.id, regional_expert2.id)
        expect(local_antenne.referencement_coverages.first.anomalie_details['extra_insee_codes']).to contain_exactly("#{bonnétable.insee_code}", "#{beaufay.insee_code}", "#{jauzé.insee_code}", "#{briosne.insee_code}")
      end
    end

    context 'des experts au niveau régional avec des territories spécifiques sont plusieurs à couvrir le même sujet' do
      let!(:regional_expert1) { create(:expert_with_users, antenne: regional_antenne, communes: communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
      let!(:regional_expert2) { create(:expert_with_users, antenne: regional_antenne, communes: communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }

      before { subject.call }

      it do
        expect(local_antenne.referencement_coverages.first.anomalie).to eq('extra_insee_codes')
        expect(local_antenne.referencement_coverages.first.coverage).to eq('regional')
        expect(local_antenne.referencement_coverages.first.anomalie_details['experts']).to contain_exactly(regional_expert1.id, regional_expert2.id)
        expect(local_antenne.referencement_coverages.first.anomalie_details['extra_insee_codes']).to contain_exactly("#{bonnétable.insee_code}", "#{beaufay.insee_code}", "#{jauzé.insee_code}", "#{briosne.insee_code}")
      end
    end

    context 'des experts au niveau local et régional sont plusieurs à couvrir le même sujet' do
      let!(:local_expert) { create(:expert_with_users, antenne: local_antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
      let!(:regional_expert) { create(:expert_with_users, antenne: regional_antenne, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }

      before { subject.call }

      it do
        expect(local_antenne.referencement_coverages.first.anomalie).to eq('extra_insee_codes')
        expect(local_antenne.referencement_coverages.first.coverage).to eq('mixte')
        expect(local_antenne.referencement_coverages.first.anomalie_details['experts']).to contain_exactly(local_expert.id, regional_expert.id)
        expect(local_antenne.referencement_coverages.first.anomalie_details['extra_insee_codes']).to contain_exactly("#{bonnétable.insee_code}", "#{beaufay.insee_code}", "#{jauzé.insee_code}", "#{briosne.insee_code}")
      end
    end

    context 'des experts au niveau local et régional avec des territoires specifiques sont plusieurs à couvrir le même sujet' do
      let!(:local_expert) { create(:expert_with_users, antenne: local_antenne, communes: communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }
      let!(:regional_expert) { create(:expert_with_users, antenne: regional_antenne, communes: communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }

      before { subject.call }

      it do
        expect(local_antenne.referencement_coverages.first.anomalie).to eq('extra_insee_codes')
        expect(local_antenne.referencement_coverages.first.coverage).to eq('mixte')
        expect(local_antenne.referencement_coverages.first.anomalie_details['experts']).to contain_exactly(local_expert.id, regional_expert.id)
        expect(local_antenne.referencement_coverages.first.anomalie_details['extra_insee_codes']).to contain_exactly("#{bonnétable.insee_code}", "#{beaufay.insee_code}", "#{jauzé.insee_code}", "#{briosne.insee_code}")
      end
    end

    context 'pas d’utilisateurs sur ce sujet' do
      let!(:expert_without_users) { create(:expert, antenne: regional_antenne, communes: communes, experts_subjects: [create(:expert_subject, institution_subject: institution_subject)]) }

      before { subject.call }

      it do
        expect(local_antenne.referencement_coverages.first.anomalie).to eq('no_user')
        expect(local_antenne.referencement_coverages.first.coverage).to eq('regional')
        expect(local_antenne.referencement_coverages.first.anomalie_details['experts']).to contain_exactly(expert_without_users.id)
      end
    end
  end
end
