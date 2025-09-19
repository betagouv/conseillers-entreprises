# spec/models/match_filter_spec.rb

require 'rails_helper'

RSpec.describe MatchFilter do

  describe 'associations' do
    let(:match_filter) { build(:match_filter) }
    let(:institution) { create(:institution) }
    let(:antenne) { create(:antenne, institution: institution) }
    let(:a_subject) { create(:subject) }
    let(:expert) { create(:expert, antenne: antenne) }

    it 'belongs to antenne' do
      match_filter.antenne = antenne
      expect(match_filter.antenne).to eq(antenne)
    end

    it 'belongs to institution' do
      match_filter.institution = institution
      expect(match_filter.institution).to eq(institution)
    end

    it 'has and belongs to many subjects' do
      match_filter.subjects << a_subject
      expect(match_filter.subjects).to include(a_subject)
    end

    describe 'has many experts through filtrable_element' do
      context 'when filtrable_element is an antenne' do
        let(:match_filter) { create(:match_filter, antenne: antenne) }

        it 'has many experts' do
          expect(match_filter.experts).to include(expert)
        end
      end

      context 'when filtrable_element is an institution' do
        let(:match_filter) { create(:match_filter, institution: institution) }

        it 'has many experts' do
          expect(match_filter.experts).to include(expert)
        end
      end
    end

    describe 'has many experts_subjects through experts' do
      let!(:match_filter) { create(:match_filter, antenne: antenne) }
      let!(:expert_subject) { create(:expert_subject, expert: expert, subject: a_subject) }

      it 'has many experts_subjects' do
        expect(match_filter.experts_subjects.map(&:subject)).to include(a_subject)
      end
    end
  end

  describe '#raw_accepted_naf_codes' do
    let(:match_filter) { create :match_filter, :for_antenne, accepted_naf_codes: accepted_naf_codes }

    subject { match_filter.raw_accepted_naf_codes }

    context 'when accepted_naf_codes is not empty' do
      let(:accepted_naf_codes) { ['1101Z', '1102A', '1102B'] }

      it 'returns a string of accepted_naf_codes joined by space' do
        is_expected.to eq('1101Z 1102A 1102B')
      end
    end

    context 'when accepted_naf_codes is empty' do
      let(:accepted_naf_codes) { [] }

      it 'returns empty string' do
        expect(match_filter.raw_accepted_naf_codes).to eq ""
      end
    end
  end

  describe '#accepted_naf_codes' do
    let(:match_filter) { create :match_filter, :for_antenne, raw_accepted_naf_codes: raw_accepted_naf_codes }

    subject { match_filter.accepted_naf_codes }

    context 'with empty data' do
      let(:raw_accepted_naf_codes) { '' }

      it { is_expected.to eq [] }
    end

    context 'with proper values' do
      let(:raw_accepted_naf_codes) { '90.01Z 9002Z' }

      it { is_expected.to eq ["9001Z", "9002Z"] }
    end
  end

  describe '#raw_excluded_naf_codes' do
    let(:match_filter) { create(:match_filter, :for_antenne, excluded_naf_codes: excluded_naf_codes) }

    subject { match_filter.raw_excluded_naf_codes }

    context 'when excluded_naf_codes is not empty' do
      let(:excluded_naf_codes) { ['1101Z', '1102A', '1102B'] }

      it 'returns a string of excluded_naf_codes joined by space' do
        is_expected.to eq('1101Z 1102A 1102B')
      end
    end

    context 'when excluded_naf_codes is empty' do
      let(:excluded_naf_codes) { [] }

      it 'returns empty string' do
        is_expected.to eq ""
      end
    end
  end

  describe '#raw_accepted_legal_forms' do
    let(:match_filter) { create(:match_filter, :for_antenne, accepted_legal_forms: accepted_legal_forms) }
    let(:accepted_legal_forms) { ['SA', 'SARL'] }

    subject { match_filter.raw_accepted_legal_forms }

    context 'when accepted_legal_forms is not empty' do
      it 'returns a string of accepted_legal_forms joined by space' do
        is_expected.to eq('SA SARL')
      end
    end

    context 'when accepted_legal_forms is empty' do
      let(:accepted_legal_forms) { [] }

      it 'returns empty string' do
        is_expected.to eq ""
      end
    end
  end

  describe '#raw_excluded_legal_forms' do
    let(:match_filter) { create(:match_filter, :for_antenne, raw_excluded_legal_forms: excluded_legal_forms) }

    subject { match_filter.raw_excluded_legal_forms }

    context 'when excluded_legal_forms is not empty' do
      let(:excluded_legal_forms) { ['SA', 'SARL'] }

      it 'returns a string of excluded_legal_forms joined by space' do
        is_expected.to eq('SA SARL')
      end
    end

    context 'when excluded_legal_forms is empty' do
      let(:excluded_legal_forms) { [] }

      it 'returns empty string' do
        is_expected.to eq ""
      end
    end
  end

  describe '#filter_types' do
    let(:antenne) { create(:antenne) }

    context 'with no filters set' do
      let(:match_filter) { create(:match_filter, antenne: antenne) }

      it 'returns an empty array' do
        expect(match_filter.filter_types).to eq []
      end
    end

    context 'with a single filter set' do
      let(:match_filter) { create(:match_filter, antenne: antenne, min_years_of_existence: 2) }

      it 'returns an array with one filter type' do
        expect(match_filter.filter_types).to eq [:min_years_of_existence]
      end
    end

    context 'with multiple filters set' do
      let(:match_filter) do
        create(:match_filter,
               antenne: antenne,
               min_years_of_existence: 2,
               effectif_min: 10,
               accepted_naf_codes: ['1101Z', '1102A'])
      end

      it 'returns an array with all filter types that have values' do
        expect(match_filter.filter_types).to include(:min_years_of_existence, :effectif_min, :raw_accepted_naf_codes)
        expect(match_filter.filter_types.length).to eq 3
      end
    end

    context 'with subjects associated' do
      let(:subject1) { create(:subject) }
      let(:subject2) { create(:subject) }
      let(:match_filter) do
        filter = create(:match_filter, antenne: antenne, effectif_max: 50)
        filter.subjects << [subject1, subject2]
        filter
      end

      it 'returns filter types including subjects' do
        expect(match_filter.filter_types).to include(:effectif_max, :subjects)
        expect(match_filter.filter_types.length).to eq 2
      end
    end
  end
end
