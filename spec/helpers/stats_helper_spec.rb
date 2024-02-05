require 'rails_helper'

describe StatsHelper do
  describe "build_manager_antennes_collection" do
    login_user
    let(:institution) { create :institution }

    subject { helper.build_manager_antennes_collection(current_user) }

    context 'Regional antenne' do
      let(:regional_antenne) { create :antenne, :regional, institution: institution }

      before { current_user.managed_antennes << [regional_antenne] }

      context 'Antenne regional qui a des experts et des antennes locales' do
        let!(:local_antenne) { create :antenne, :local, institution: institution, parent_antenne: regional_antenne }
        let!(:expert_local) { create :expert_with_users, antenne: local_antenne }
        let!(:expert_subject_local) { create :expert_subject, expert: expert_local }
        let!(:expert_regional) { create :expert_with_users, antenne: regional_antenne }
        let!(:expert_subject_regional) { create :expert_subject, expert: expert_regional }

        it do
          is_expected.to contain_exactly({ name: regional_antenne.name, id: regional_antenne.id, territorial_level: 1 }, { name: I18n.t('helpers.stats_helper.antenne_with_locales', name: regional_antenne.name), id: regional_antenne.id, territorial_level: 1 }, { name: local_antenne.name, id: local_antenne.id, territorial_level: 2 })
        end
      end

      context "Antenne regional qui n’a pas d'expert mais des antennes locales" do
        let!(:local_antenne) { create :antenne, :local, institution: institution, parent_antenne: regional_antenne }
        let!(:expert) { create :expert_with_users, antenne: local_antenne }
        let!(:expert_subject) { create :expert_subject, expert: expert }

        it do
          is_expected.to contain_exactly({ name: I18n.t('helpers.stats_helper.antenne_with_locales', name: regional_antenne.name), id: regional_antenne.id, territorial_level: 1 },
                                         { name: local_antenne.name, id: local_antenne.id, territorial_level: 2 },)
        end
      end

      context "Antenne regional sans antenne locale" do
        let!(:expert) { create :expert_with_users, antenne: regional_antenne }
        let!(:expert_subject) { create :expert_subject, expert: expert }

        it { is_expected.to contain_exactly({ name: regional_antenne.name, id: regional_antenne.id, territorial_level: 1 }) }
      end
    end

    context 'National antenne' do
      let(:national_antenne) { create :antenne, :national, institution: institution }

      before { current_user.managed_antennes << [national_antenne] }

      context 'Antenne national sans antennes locales' do
        let!(:expert) { create :expert_with_users, antenne: national_antenne }
        let!(:expert_subject) { create :expert_subject, expert: expert }

        it { is_expected.to contain_exactly({ name: national_antenne.name, id: national_antenne.id, territorial_level: 0 }) }
      end

      context 'Antenne national avec des experts avec des antennes locales' do
        let!(:local_antenne) { create :antenne, :local, institution: institution }
        let!(:local_expert) { create :expert_with_users, antenne: local_antenne }
        let!(:national_expert) { create :expert_with_users, antenne: national_antenne }
        let!(:expert_subject_local) { create :expert_subject, expert: local_expert }
        let!(:expert_subject_national) { create :expert_subject, expert: national_expert }

        it do
          is_expected.to contain_exactly({ name: national_antenne.name, id: national_antenne.id, territorial_level: 0 },
                                         { name: I18n.t('helpers.stats_helper.antenne_with_locales', name: national_antenne.name), id: national_antenne.id, territorial_level: 0 },
                                         { name: local_antenne.name, id: local_antenne.id, territorial_level: 2 })
        end
      end

      context 'Antenne national sans expert avec des antennes locales' do
        let!(:local_antenne) { create :antenne, :local, institution: institution }
        let!(:expert) { create :expert_with_users, antenne: local_antenne }
        let!(:expert_subject) { create :expert_subject, expert: expert }

        it do
          is_expected.to contain_exactly({ name: I18n.t('helpers.stats_helper.antenne_with_locales', name: national_antenne.name), id: national_antenne.id, territorial_level: 0 },
                                         { name: local_antenne.name, id: local_antenne.id, territorial_level: 2 })
        end
      end
    end
  end
end
