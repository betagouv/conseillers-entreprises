# frozen_string_literal: true

require 'rails_helper'
describe TimeDurationService::Months do
  describe 'call' do
    subject { described_class.new.call }

    context '1rst quarter' do
      it do
        travel_to('2025-01-20') do
          is_expected.to contain_exactly(['01/12/2024'.to_date, '31/12/2024'.to_date], ['01/11/2024'.to_date, '30/11/2024'.to_date], ['01/10/2024'.to_date, '31/10/2024'.to_date], ['01/09/2024'.to_date, '30/09/2024'.to_date], ['01/08/2024'.to_date, '31/08/2024'.to_date], ['01/07/2024'.to_date, '31/07/2024'.to_date], ['01/06/2024'.to_date, '30/06/2024'.to_date], ['01/05/2024'.to_date, '31/05/2024'.to_date], ['01/04/2024'.to_date, '30/04/2024'.to_date], ['01/03/2024'.to_date, '31/03/2024'.to_date], ['01/02/2024'.to_date, '29/02/2024'.to_date], ['01/01/2024'.to_date, '31/01/2024'.to_date], ['01/12/2023'.to_date, '31/12/2023'.to_date], ['01/11/2023'.to_date, '30/11/2023'.to_date], ['01/10/2023'.to_date, '31/10/2023'.to_date], ['01/09/2023'.to_date, '30/09/2023'.to_date], ['01/08/2023'.to_date, '31/08/2023'.to_date], ['01/07/2023'.to_date, '31/07/2023'.to_date], ['01/06/2023'.to_date, '30/06/2023'.to_date], ['01/05/2023'.to_date, '31/05/2023'.to_date], ['01/04/2023'.to_date, '30/04/2023'.to_date], ['01/03/2023'.to_date, '31/03/2023'.to_date], ['01/02/2023'.to_date, '28/02/2023'.to_date], ['01/01/2023'.to_date, '31/01/2023'.to_date])
        end
      end
    end

    context '2nd quarter' do
      it do
        travel_to('2025-05-20') do
          is_expected.to contain_exactly(['01/04/2025'.to_date, '30/04/2025'.to_date], ['01/03/2025'.to_date, '31/03/2025'.to_date], ['01/02/2025'.to_date, '28/02/2025'.to_date], ['01/01/2025'.to_date, '31/01/2025'.to_date], ['01/12/2024'.to_date, '31/12/2024'.to_date], ['01/11/2024'.to_date, '30/11/2024'.to_date], ['01/10/2024'.to_date, '31/10/2024'.to_date], ['01/09/2024'.to_date, '30/09/2024'.to_date], ['01/08/2024'.to_date, '31/08/2024'.to_date], ['01/07/2024'.to_date, '31/07/2024'.to_date], ['01/06/2024'.to_date, '30/06/2024'.to_date], ['01/05/2024'.to_date, '31/05/2024'.to_date], ['01/04/2024'.to_date, '30/04/2024'.to_date], ['01/03/2024'.to_date, '31/03/2024'.to_date], ['01/02/2024'.to_date, '29/02/2024'.to_date], ['01/01/2024'.to_date, '31/01/2024'.to_date])
        end
      end
    end
  end
end
