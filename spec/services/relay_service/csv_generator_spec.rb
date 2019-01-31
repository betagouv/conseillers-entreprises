# frozen_string_literal: true

require 'rails_helper'

describe RelayService::CSVGenerator do
  describe 'generate_statistics_csv' do
    context 'one diagnosis' do
      let(:user) { create :user, full_name: 'Jean Bon', institution: 'DINSIC' }
      let(:company) { create :company, name: 'COMPANY NAME' }
      let(:facility) { create :facility, company: company }
      let!(:diagnosis) { create :diagnosis, facility: facility, advisor: user, happened_on: Date.parse('2017-10-10') }
      let(:diagnosed_need) do
        create :diagnosed_need, diagnosis: diagnosis, question_label: 'Need money ?', content: 'Very poor, much sad'
      end
      let(:expected_csv) do
        File.read(Rails.root.join('spec', 'fixtures', 'relay_statistic_csv_fixture.csv'))
      end

      before do
        create :match, diagnosed_need: diagnosed_need,
               expert_full_name: 'Expert Joe',
               expert_institution_name: 'Educ Nat',
               status: :done,
               taken_care_of_at: Date.parse('2017-10-21'),
               closed_at: Date.parse('2017-11-04')
      end

      it 'creates the csv with the right data' do
        csv = described_class.generate_statistics_csv([diagnosis]).force_encoding('UTF-8')
        csv_without_bom = csv.delete("\xEF\xBB\xBF")
        expect(csv_without_bom).to eq(expected_csv)
      end
    end
  end
end
