require 'rails_helper'

describe TimeDurationService do
  describe '#period_name' do
    it do
      expect(described_class.period_name(('01/07/2024'.to_date)..('31/07/2024'.to_date))).to eq '2024-7'
      expect(described_class.period_name(('01/2024'.to_date)..('31/03/2024'.to_date))).to eq '2024T1'
      expect(described_class.period_name(('07/03/2024'.to_date)..('08/04/2024'.to_date))).to eq '07/03/2024-08/04/2024'
    end
  end
end
