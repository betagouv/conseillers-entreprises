# frozen_string_literal: true
require 'rails_helper'

RSpec.describe StatsController, type: :controller do

  describe 'history_date_ranges' do
    subject { controller.instance_eval{ history_date_ranges } }

    before { create :user, created_at: date_1}

    context 'with a single recent user' do
      let(:date_1) { Time.zone.now }

      it 'returns a single one-month range' do
        is_expected.to eq [date_1.beginning_of_month..(date_1 + 1.month).beginning_of_month]
      end
    end

    context 'with a 15-month old user' do
      let(:date_1) { Time.zone.now - 15.months }

      it 'returns a 15 ranges array' do
        subject.count eq 15
      end
    end
  end
end
