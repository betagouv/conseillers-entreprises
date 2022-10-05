require 'rails_helper'

RSpec.describe Badge, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :color }
    it { is_expected.to validate_presence_of :category }
  end

  describe 'touch solicitations' do
    let(:date1) { Time.zone.now.beginning_of_day }
    let(:date2) { date1 + 1.minute }
    let(:date3) { date1 + 2.minutes }

    let(:solicitation) { travel_to(date1) { create :solicitation, badges: initial_badges } }
    let(:badge) { travel_to(date2) { create :badge } }

    before do
      badge
      solicitation
    end

    subject { solicitation.reload.updated_at }

    context 'when a badge is added to a solicitation' do
      let(:initial_badges) { [] }

      before { travel_to(date3) { solicitation.badges = [badge] } }

      it { is_expected.to eq date3 }
    end

    context 'when a badge is removed from a solicitation' do
      let(:initial_badges) { [badge] }

      before { travel_to(date3) { solicitation.badges = [] } }

      it { is_expected.to eq date3 }
    end

    context 'when a badge is updated' do
      let(:initial_badges) { [badge] }

      before { travel_to(date3) { badge.update(title: 'New title') } }

      it { is_expected.to eq date3 }
    end
  end

  describe 'touch needs' do
    let(:date1) { Time.zone.now.beginning_of_day }
    let(:date2) { date1 + 1.minute }
    let(:date3) { date1 + 2.minutes }

    let(:need) { travel_to(date1) { create :need, badges: initial_badges } }
    let(:badge) { travel_to(date2) { create :badge } }

    before do
      badge
      need
    end

    subject { need.reload.updated_at }

    context 'when a badge is added to a need' do
      let(:initial_badges) { [] }

      before { travel_to(date3) { need.badges = [badge] } }

      it { is_expected.to eq date3 }
    end

    context 'when a badge is removed from a need' do
      let(:initial_badges) { [badge] }

      before { travel_to(date3) { need.badges = [] } }

      it { is_expected.to eq date3 }
    end

    context 'when a badge is updated' do
      let(:initial_badges) { [badge] }

      before { travel_to(date3) { badge.update(title: 'New title') } }

      it { is_expected.to eq date3 }
    end
  end
end
