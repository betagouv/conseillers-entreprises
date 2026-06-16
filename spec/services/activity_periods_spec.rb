require 'rails_helper'

describe ActivityPeriods do
  describe '#period_name' do
    it do
      expect(described_class.period_name(('01/07/2024'.to_date)..('31/07/2024'.to_date))).to eq '2024-7'
      expect(described_class.period_name(('01/2024'.to_date)..('31/03/2024'.to_date))).to eq '2024T1'
      expect(described_class.period_name(('07/03/2024'.to_date)..('08/04/2024'.to_date))).to eq '07/03/2024-08/04/2024'
    end
  end

  describe 'months' do
    subject { described_class.months }

    context 'beginning of the year (January)' do
      it 'returns only the 12 months of the previous year' do
        travel_to('2025-01-20') do
          # January 2025 is not finished yet, so only 2024 months are returned
          is_expected.to contain_exactly(
            '12/2024'.to_date.all_month,
            '11/2024'.to_date.all_month,
            '10/2024'.to_date.all_month,
            '09/2024'.to_date.all_month,
            '08/2024'.to_date.all_month,
            '07/2024'.to_date.all_month,
            '06/2024'.to_date.all_month,
            '05/2024'.to_date.all_month,
            '04/2024'.to_date.all_month,
            '03/2024'.to_date.all_month,
            '02/2024'.to_date.all_month,
            '01/2024'.to_date.all_month
          )
        end
      end
    end

    context 'middle of the year (May)' do
      it 'returns past months of current year and all months of previous year' do
        travel_to('2025-05-20') do
          # May 2025 is not finished yet, so we get Jan-Apr 2025 + all of 2024
          is_expected.to contain_exactly(
            '04/2025'.to_date.all_month,
            '03/2025'.to_date.all_month,
            '02/2025'.to_date.all_month,
            '01/2025'.to_date.all_month,
            '12/2024'.to_date.all_month,
            '11/2024'.to_date.all_month,
            '10/2024'.to_date.all_month,
            '09/2024'.to_date.all_month,
            '08/2024'.to_date.all_month,
            '07/2024'.to_date.all_month,
            '06/2024'.to_date.all_month,
            '05/2024'.to_date.all_month,
            '04/2024'.to_date.all_month,
            '03/2024'.to_date.all_month,
            '02/2024'.to_date.all_month,
            '01/2024'.to_date.all_month
          )
        end
      end
    end

    context 'end of the year (December)' do
      it 'returns past months of current year and all months of previous year' do
        travel_to('2025-12-20') do
          # December 2025 is not finished yet, so we get Jan-Nov 2025 + all of 2024
          is_expected.to contain_exactly(
            '11/2025'.to_date.all_month,
            '10/2025'.to_date.all_month,
            '09/2025'.to_date.all_month,
            '08/2025'.to_date.all_month,
            '07/2025'.to_date.all_month,
            '06/2025'.to_date.all_month,
            '05/2025'.to_date.all_month,
            '04/2025'.to_date.all_month,
            '03/2025'.to_date.all_month,
            '02/2025'.to_date.all_month,
            '01/2025'.to_date.all_month,
            '12/2024'.to_date.all_month,
            '11/2024'.to_date.all_month,
            '10/2024'.to_date.all_month,
            '09/2024'.to_date.all_month,
            '08/2024'.to_date.all_month,
            '07/2024'.to_date.all_month,
            '06/2024'.to_date.all_month,
            '05/2024'.to_date.all_month,
            '04/2024'.to_date.all_month,
            '03/2024'.to_date.all_month,
            '02/2024'.to_date.all_month,
            '01/2024'.to_date.all_month
          )
        end
      end
    end
  end

  describe 'quarters' do
    subject { described_class.quarters }

    context '1rst quarter' do
      it do
        travel_to('2025-01-20') do
          is_expected.to contain_exactly(
            '10/2024'.to_date.all_quarter,
            '07/2024'.to_date.all_quarter,
            '04/2024'.to_date.all_quarter,
            '01/2024'.to_date.all_quarter,
            '10/2023'.to_date.all_quarter,
            '07/2023'.to_date.all_quarter,
            '04/2023'.to_date.all_quarter,
            '01/2023'.to_date.all_quarter
          )
        end
      end
    end

    context '2nd quarter' do
      it do
        travel_to('2025-05-20') do
          is_expected.to contain_exactly(
            '01/2025'.to_date.all_quarter,
            '10/2024'.to_date.all_quarter,
            '07/2024'.to_date.all_quarter,
            '04/2024'.to_date.all_quarter,
            '01/2024'.to_date.all_quarter
          )
        end
      end
    end

    context '3rd quarter' do
      it do
        travel_to('2025-08-20') do
          is_expected.to contain_exactly(
            '04/2025'.to_date.all_quarter,
            '01/2025'.to_date.all_quarter,
            '10/2024'.to_date.all_quarter,
            '07/2024'.to_date.all_quarter,
            '04/2024'.to_date.all_quarter,
            '01/2024'.to_date.all_quarter
          )
        end
      end
    end

    context 'last quarter' do
      it do
        travel_to('2025-11-20') do
          is_expected.to contain_exactly(
            '07/2025'.to_date.all_quarter,
            '04/2025'.to_date.all_quarter,
            '01/2025'.to_date.all_quarter,
            '10/2024'.to_date.all_quarter,
            '07/2024'.to_date.all_quarter,
            '04/2024'.to_date.all_quarter,
            '01/2024'.to_date.all_quarter
          )
        end
      end
    end
  end

  describe 'years' do
    subject { described_class.years }

    context '1rst quarter' do
      it do
        travel_to('2025-01-20') do
          is_expected.to contain_exactly('01/2024'.to_date.all_year, '01/2023'.to_date.all_year)
        end
      end
    end

    context '2nd quarter' do
      it do
        travel_to('2025-04-20') do
          is_expected.to contain_exactly('01/2024'.to_date.all_year)
        end
      end
    end
  end
end
