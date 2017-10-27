# frozen_string_literal: true

require 'rails_helper'

describe TerritoryUserService::CSVGenerator do
  describe 'generate_statistics_csv' do
    context 'one diagnosis' do
      let(:user) { create :user, first_name: 'Jean', last_name: 'Bon', institution: 'SGMAP' }
      let(:company) { create :company, name: 'COMPANY NAME' }
      let(:facility) { create :facility, company: company }
      let(:visit) { create :visit, facility: facility, advisor: user, happened_on: Date.parse('2017-10-10') }
      let!(:diagnosis) { create :diagnosis, visit: visit }
      let!(:diagnosed_need) do
        create :diagnosed_need, diagnosis: diagnosis, question_label: 'Need money ?', content: 'Very poor, much sad'
      end
      let(:expected_csv) do
        File.read(Rails.root.join('spec/fixtures/territory_user_statistic_csv_fixture.csv'))
      end

      before do
        create :selected_assistance_expert, diagnosed_need: diagnosed_need,
                                            expert_full_name: 'Expert Joe',
                                            expert_institution_name: 'Educ Nat',
                                            status: :done,
                                            taken_care_of_at: Date.parse('2017-10-21'),
                                            closed_at: Date.parse('2017-11-04')
      end

      it 'creates the csv with the right data' do
        csv_without_bom = described_class.generate_statistics_csv([diagnosis])[3..-1].force_encoding('UTF-8')
        expect(csv_without_bom).to eq(expected_csv)
      end
    end
  end
end
