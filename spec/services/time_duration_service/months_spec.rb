require 'rails_helper'

describe TimeDurationService::Months do
  describe 'call' do
    subject { described_class.new.call }

    context 'beginning of the year (January)' do
      it 'returns only the 12 months of the previous year' do
        travel_to('2025-01-20') do
          # January 2025 is not finished yet, so only 2024 months are returned
          is_expected.to contain_exactly(
            ('01/12/2024'.to_date)..('31/12/2024'.to_date),
            ('01/11/2024'.to_date)..('30/11/2024'.to_date),
            ('01/10/2024'.to_date)..('31/10/2024'.to_date),
            ('01/09/2024'.to_date)..('30/09/2024'.to_date),
            ('01/08/2024'.to_date)..('31/08/2024'.to_date),
            ('01/07/2024'.to_date)..('31/07/2024'.to_date),
            ('01/06/2024'.to_date)..('30/06/2024'.to_date),
            ('01/05/2024'.to_date)..('31/05/2024'.to_date),
            ('01/04/2024'.to_date)..('30/04/2024'.to_date),
            ('01/03/2024'.to_date)..('31/03/2024'.to_date),
            ('01/02/2024'.to_date)..('29/02/2024'.to_date),
            ('01/01/2024'.to_date)..('31/01/2024'.to_date)
          )
        end
      end
    end

    context 'middle of the year (May)' do
      it 'returns past months of current year and all months of previous year' do
        travel_to('2025-05-20') do
          # May 2025 is not finished yet, so we get Jan-Apr 2025 + all of 2024
          is_expected.to contain_exactly(
            ('01/04/2025'.to_date)..('30/04/2025'.to_date),
            ('01/03/2025'.to_date)..('31/03/2025'.to_date),
            ('01/02/2025'.to_date)..('28/02/2025'.to_date),
            ('01/01/2025'.to_date)..('31/01/2025'.to_date),
            ('01/12/2024'.to_date)..('31/12/2024'.to_date),
            ('01/11/2024'.to_date)..('30/11/2024'.to_date),
            ('01/10/2024'.to_date)..('31/10/2024'.to_date),
            ('01/09/2024'.to_date)..('30/09/2024'.to_date),
            ('01/08/2024'.to_date)..('31/08/2024'.to_date),
            ('01/07/2024'.to_date)..('31/07/2024'.to_date),
            ('01/06/2024'.to_date)..('30/06/2024'.to_date),
            ('01/05/2024'.to_date)..('31/05/2024'.to_date),
            ('01/04/2024'.to_date)..('30/04/2024'.to_date),
            ('01/03/2024'.to_date)..('31/03/2024'.to_date),
            ('01/02/2024'.to_date)..('29/02/2024'.to_date),
            ('01/01/2024'.to_date)..('31/01/2024'.to_date)
          )
        end
      end
    end

    context 'end of the year (December)' do
      it 'returns past months of current year and all months of previous year' do
        travel_to('2025-12-20') do
          # December 2025 is not finished yet, so we get Jan-Nov 2025 + all of 2024
          is_expected.to contain_exactly(
            ('01/11/2025'.to_date)..('30/11/2025'.to_date),
            ('01/10/2025'.to_date)..('31/10/2025'.to_date),
            ('01/09/2025'.to_date)..('30/09/2025'.to_date),
            ('01/08/2025'.to_date)..('31/08/2025'.to_date),
            ('01/07/2025'.to_date)..('31/07/2025'.to_date),
            ('01/06/2025'.to_date)..('30/06/2025'.to_date),
            ('01/05/2025'.to_date)..('31/05/2025'.to_date),
            ('01/04/2025'.to_date)..('30/04/2025'.to_date),
            ('01/03/2025'.to_date)..('31/03/2025'.to_date),
            ('01/02/2025'.to_date)..('28/02/2025'.to_date),
            ('01/01/2025'.to_date)..('31/01/2025'.to_date),
            ('01/12/2024'.to_date)..('31/12/2024'.to_date),
            ('01/11/2024'.to_date)..('30/11/2024'.to_date),
            ('01/10/2024'.to_date)..('31/10/2024'.to_date),
            ('01/09/2024'.to_date)..('30/09/2024'.to_date),
            ('01/08/2024'.to_date)..('31/08/2024'.to_date),
            ('01/07/2024'.to_date)..('31/07/2024'.to_date),
            ('01/06/2024'.to_date)..('30/06/2024'.to_date),
            ('01/05/2024'.to_date)..('31/05/2024'.to_date),
            ('01/04/2024'.to_date)..('30/04/2024'.to_date),
            ('01/03/2024'.to_date)..('31/03/2024'.to_date),
            ('01/02/2024'.to_date)..('29/02/2024'.to_date),
            ('01/01/2024'.to_date)..('31/01/2024'.to_date)
          )
        end
      end
    end
  end
end
