# frozen_string_literal: true

require 'rails_helper'
describe TimeDurationService::Quarters do
  describe 'call' do
    subject { described_class.new.call }

    context '1rst quarter' do
      it do
        travel_to('2025-01-20') do
          is_expected.to contain_exactly(['Tue, 01 Oct 2024'.to_date, 'Tue, 31 Dec 2024'.to_date], ['Mon, 01 Jul 2024'.to_date, 'Mon, 30 Sep 2024'.to_date], ['Mon, 01 Apr 2024'.to_date, 'Sun, 30 Jun 2024'.to_date], ['Mon, 01 Jan 2024'.to_date, 'Sun, 31 Mar 2024'.to_date], ['Sun, 01 Oct 2023'.to_date, 'Sun, 31 Dec 2023'.to_date], ['Sat, 01 Jul 2023'.to_date, 'Sat, 30 Sep 2023'.to_date], ['Sat, 01 Apr 2023'.to_date, 'Fri, 30 Jun 2023'.to_date], ['Sun, 01 Jan 2023'.to_date, 'Fri, 31 Mar 2023'.to_date])
        end
      end
    end

    context '2nd quarter' do
      it do
        travel_to('2025-05-20') do
          is_expected.to contain_exactly(['Mon, 01 Jan 2024'.to_date, 'Sun, 31 Mar 2024'.to_date], ['Mon, 01 Apr 2024'.to_date, 'Sun, 30 Jun 2024'.to_date], ['Mon, 01 Jul 2024'.to_date, 'Mon, 30 Sep 2024'.to_date], ['Tue, 01 Oct 2024'.to_date, 'Tue, 31 Dec 2024'.to_date], ['Wed, 01 Jan 2025'.to_date, 'Mon, 31 Mar 2025'.to_date])
        end
      end
    end

    context '3rd quarter' do
      it do
        travel_to('2025-08-20') do
          is_expected.to contain_exactly(['Mon, 01 Jan 2024'.to_date, 'Sun, 31 Mar 2024'.to_date], ['Mon, 01 Apr 2024'.to_date, 'Sun, 30 Jun 2024'.to_date], ['Mon, 01 Jul 2024'.to_date, 'Mon, 30 Sep 2024'.to_date], ['Tue, 01 Oct 2024'.to_date, 'Tue, 31 Dec 2024'.to_date], ['Wed, 01 Jan 2025'.to_date, 'Mon, 31 Mar 2025'.to_date], ['Tue, 01 Apr 2025'.to_date, 'Mon, 30 Jun 2025'.to_date])
        end
      end
    end

    context 'last quarter' do
      it do
        travel_to('2025-11-20') do
          is_expected.to contain_exactly(['Mon, 01 Jan 2024'.to_date, 'Sun, 31 Mar 2024'.to_date], ['Mon, 01 Apr 2024'.to_date, 'Sun, 30 Jun 2024'.to_date], ['Mon, 01 Jul 2024'.to_date, 'Mon, 30 Sep 2024'.to_date], ['Tue, 01 Oct 2024'.to_date, 'Tue, 31 Dec 2024'.to_date], ['Wed, 01 Jan 2025'.to_date, 'Mon, 31 Mar 2025'.to_date], ['Tue, 01 Apr 2025'.to_date, 'Mon, 30 Jun 2025'.to_date], ['Wed, 01 Jul 2025'.to_date, 'Tue, 30 Sep 2025'.to_date])
        end
      end
    end
  end
end
