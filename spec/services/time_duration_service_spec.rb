# frozen_string_literal: true

require 'rails_helper'
describe TimeDurationService do
  describe 'past_year_quarters' do
    subject { described_class.past_year_quarters }

    context '1rst quarter' do
      before { travel_to('2025-01-20') }

      it {
  is_expected.to contain_exactly(['Tue, 01 Oct 2024'.to_date, 'Tue, 31 Dec 2024'.to_date], ['Mon, 01 Jul 2024'.to_date, 'Mon, 30 Sep 2024'.to_date], ['Mon, 01 Apr 2024'.to_date, 'Sun, 30 Jun 2024'.to_date], ['Mon, 01 Jan 2024'.to_date, 'Sun, 31 Mar 2024'.to_date], ['Sun, 01 Oct 2023'.to_date, 'Sun, 31 Dec 2023'.to_date], ['Sat, 01 Jul 2023'.to_date, 'Sat, 30 Sep 2023'.to_date], ['Sat, 01 Apr 2023'.to_date, 'Fri, 30 Jun 2023'.to_date], ['Sun, 01 Jan 2023'.to_date, 'Fri, 31 Mar 2023'.to_date])
}
    end

    context '2nd quarter' do
      before { travel_to('2025-05-20') }

      it {
  is_expected.to contain_exactly(['Mon, 01 Jan 2024'.to_date, 'Sun, 31 Mar 2024'.to_date], ['Mon, 01 Apr 2024'.to_date, 'Sun, 30 Jun 2024'.to_date], ['Mon, 01 Jul 2024'.to_date, 'Mon, 30 Sep 2024'.to_date], ['Tue, 01 Oct 2024'.to_date, 'Tue, 31 Dec 2024'.to_date], ['Wed, 01 Jan 2025'.to_date, 'Mon, 31 Mar 2025'.to_date])
}
    end

    context '3rd quarter' do
      before { travel_to('2025-08-20') }

      it {
  is_expected.to contain_exactly(['Mon, 01 Jan 2024'.to_date, 'Sun, 31 Mar 2024'.to_date], ['Mon, 01 Apr 2024'.to_date, 'Sun, 30 Jun 2024'.to_date], ['Mon, 01 Jul 2024'.to_date, 'Mon, 30 Sep 2024'.to_date], ['Tue, 01 Oct 2024'.to_date, 'Tue, 31 Dec 2024'.to_date], ['Wed, 01 Jan 2025'.to_date, 'Mon, 31 Mar 2025'.to_date], ['Tue, 01 Apr 2025'.to_date, 'Mon, 30 Jun 2025'.to_date])
}
    end

    context 'last quarter' do
      before { travel_to('2025-11-20') }

      it {
  is_expected.to contain_exactly(['Mon, 01 Jan 2024'.to_date, 'Sun, 31 Mar 2024'.to_date], ['Mon, 01 Apr 2024'.to_date, 'Sun, 30 Jun 2024'.to_date], ['Mon, 01 Jul 2024'.to_date, 'Mon, 30 Sep 2024'.to_date], ['Tue, 01 Oct 2024'.to_date, 'Tue, 31 Dec 2024'.to_date], ['Wed, 01 Jan 2025'.to_date, 'Mon, 31 Mar 2025'.to_date], ['Tue, 01 Apr 2025'.to_date, 'Mon, 30 Jun 2025'.to_date], ['Wed, 01 Jul 2025'.to_date, 'Tue, 30 Sep 2025'.to_date])
}
    end
  end

  describe 'past_year_months' do
    subject { described_class.past_year_months }

    context '1rst quarter' do
      before { travel_to('2025-01-20') }

      it {
  is_expected.to contain_exactly(['01/12/2024'.to_date, '31/12/2024'.to_date], ['01/11/2024'.to_date, '30/11/2024'.to_date], ['01/10/2024'.to_date, '31/10/2024'.to_date], ['01/09/2024'.to_date, '30/09/2024'.to_date], ['01/08/2024'.to_date, '31/08/2024'.to_date], ['01/07/2024'.to_date, '31/07/2024'.to_date], ['01/06/2024'.to_date, '30/06/2024'.to_date], ['01/05/2024'.to_date, '31/05/2024'.to_date], ['01/04/2024'.to_date, '30/04/2024'.to_date], ['01/03/2024'.to_date, '31/03/2024'.to_date], ['01/02/2024'.to_date, '29/02/2024'.to_date], ['01/01/2024'.to_date, '31/01/2024'.to_date], ['01/12/2023'.to_date, '31/12/2023'.to_date], ['01/11/2023'.to_date, '30/11/2023'.to_date], ['01/10/2023'.to_date, '31/10/2023'.to_date], ['01/09/2023'.to_date, '30/09/2023'.to_date], ['01/08/2023'.to_date, '31/08/2023'.to_date], ['01/07/2023'.to_date, '31/07/2023'.to_date], ['01/06/2023'.to_date, '30/06/2023'.to_date], ['01/05/2023'.to_date, '31/05/2023'.to_date], ['01/04/2023'.to_date, '30/04/2023'.to_date], ['01/03/2023'.to_date, '31/03/2023'.to_date], ['01/02/2023'.to_date, '28/02/2023'.to_date], ['01/01/2023'.to_date, '31/01/2023'.to_date])
}
    end

    context '2nd quarter' do
      before { travel_to('2025-05-20') }

      it {
  is_expected.to contain_exactly(['01/04/2025'.to_date, '30/04/2025'.to_date], ['01/03/2025'.to_date, '31/03/2025'.to_date], ['01/02/2025'.to_date, '28/02/2025'.to_date], ['01/01/2025'.to_date, '31/01/2025'.to_date], ['01/12/2024'.to_date, '31/12/2024'.to_date], ['01/11/2024'.to_date, '30/11/2024'.to_date], ['01/10/2024'.to_date, '31/10/2024'.to_date], ['01/09/2024'.to_date, '30/09/2024'.to_date], ['01/08/2024'.to_date, '31/08/2024'.to_date], ['01/07/2024'.to_date, '31/07/2024'.to_date], ['01/06/2024'.to_date, '30/06/2024'.to_date], ['01/05/2024'.to_date, '31/05/2024'.to_date], ['01/04/2024'.to_date, '30/04/2024'.to_date], ['01/03/2024'.to_date, '31/03/2024'.to_date], ['01/02/2024'.to_date, '29/02/2024'.to_date], ['01/01/2024'.to_date, '31/01/2024'.to_date])
}
    end
  end
end
