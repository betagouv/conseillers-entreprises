require 'rails_helper'
describe TimeDurationService::Years do
  describe 'call' do
    subject { described_class.new.call }

    context '1rst quarter' do
      it do
        travel_to('2025-01-20') do
          is_expected.to contain_exactly(('01/01/2024'.to_date)..('31/12/2024'.to_date), ('01/01/2023'.to_date)..('31/12/2023'.to_date))
        end
      end
    end

    context '2nd quarter' do
      it do
        travel_to('2025-04-20') do
          is_expected.to contain_exactly(('01/01/2024'.to_date)..('31/12/2024'.to_date))
        end
      end
    end
  end
end
