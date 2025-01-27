require 'rails_helper'

describe StatsHelper do
  describe "stats_title" do
    subject { helper.stats_title(data, name) }

    context 'Without secondary_ count' do
      let(:data) { OpenStruct.new({ count: 34 }) }
      let(:name) { 'needs_transmitted' }

      it do
        is_expected.to eq("Besoins transmis")
      end
    end

    context 'With secondary_ count' do
      let(:data) { OpenStruct.new({ secondary_count: 4 }) }
      let(:name) { 'matches_taking_care' }

      it do
        is_expected.to eq("des besoins transmis sont en cours de prise en charge par l’institution, soit 4 besoins")
      end
    end
  end
end
