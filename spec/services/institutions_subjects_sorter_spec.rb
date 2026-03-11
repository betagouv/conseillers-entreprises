require 'rails_helper'

describe InstitutionsSubjectsSorter do
  let(:sorter_class) do
    Class.new do
      include InstitutionsSubjectsSorter
    end
  end

  subject(:sorter) { sorter_class.new }

  describe '#sorted_institutions_subjects' do
    let(:institution) { create(:institution) }
    let(:normal_theme_1) { create(:theme, label: 'Normal Theme 1') }
    let(:normal_theme_2) { create(:theme, label: 'Normal Theme 2') }
    let(:cooperation_theme) { create(:theme, label: 'Cooperation Theme') }

    subject(:result) { sorter.sorted_institutions_subjects(institution_subjects) }

    context 'with normal themes only' do
      let(:subject_1a) { create(:subject, theme: normal_theme_1, label: 'Subject 1a') }
      let(:subject_1b) { create(:subject, theme: normal_theme_1, label: 'Subject 2b') }
      let(:subject_2) { create(:subject, theme: normal_theme_2, label: 'Subject 2') }

      let(:is_1a) { create(:institution_subject, institution: institution, subject: subject_1a) }
      let(:is_1b) { create(:institution_subject, institution: institution, subject: subject_1b) }
      let(:is_2) { create(:institution_subject, institution: institution, subject: subject_2) }

      let(:institution_subjects) { [is_2, is_1b, is_1a] }

      it 'sorts by theme label then subject label' do
        expect(result).to eq([is_1a, is_1b, is_2])
      end
    end

    context 'with a theme having a cooperation' do
      let(:cooperation) { create(:cooperation, institution: institution) }

      let(:normal_subject) { create(:subject, theme: normal_theme_1, label: 'Normal Subject') }
      let(:cooperation_subject) { create(:subject, theme: cooperation_theme, label: 'Cooperation Subject') }
      let(:is_normal) { create(:institution_subject, institution: institution, subject: normal_subject) }
      let(:is_cooperation) { create(:institution_subject, institution: institution, subject: cooperation_subject) }
      let(:institution_subjects) { [is_cooperation, is_normal] }

      before { create(:cooperation_theme, cooperation: cooperation, theme: cooperation_theme) }

      it 'places the cooperation theme after the normal theme' do
        expect(result).to eq([is_normal, is_cooperation])
      end
    end

    context 'with a theme having territorial_zones' do
      let(:territorial_theme) do
        create(:theme, label: 'Theme 2',
               territorial_zones: [create(:territorial_zone, zone_type: :departement, code: '22')])
      end
      let(:normal_subject) { create(:subject, theme: normal_theme_1, label: 'Normal Subject') }
      let(:territorial_subject) { create(:subject, theme: territorial_theme, label: 'Territorial Subject') }
      let(:is_normal) { create(:institution_subject, institution: institution, subject: normal_subject) }
      let(:is_territorial) { create(:institution_subject, institution: institution, subject: territorial_subject) }
      let(:institution_subjects) { [is_territorial, is_normal] }

      it 'places the territorial theme after the normal theme' do
        expect(result).to eq([is_normal, is_territorial])
      end
    end
  end
end