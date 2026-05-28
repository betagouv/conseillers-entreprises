require 'rails_helper'
describe TimeDurationService::Quarters do
  describe 'call' do
    subject { described_class.new.call }

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
end
