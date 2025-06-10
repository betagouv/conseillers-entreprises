# frozen_string_literal: true

require 'rails_helper'

describe ExpertsHelper do
  describe 'main_user_absent?' do
    let(:user) { create :user, absence_start_at: absence_start_at, absence_end_at: absence_end_at }
    let!(:expert) { create :expert, users: users }

    subject { helper.main_user_absent? expert }

    context 'many users expert' do
      let(:absence_start_at) { 10.days.ago }
      let(:absence_end_at) { 5.days.since }
      let(:users) { [user, create(:user)] }

      it { is_expected.to be false }
    end

    context 'no absences' do
      let(:absence_start_at) { nil }
      let(:absence_end_at) { nil }
      let(:users) { [user] }

      it { is_expected.to be false }
    end

    context 'not started absence' do
      let(:absence_start_at) { 5.days.since }
      let(:absence_end_at) { 20.days.since }
      let(:users) { [user] }

      it { is_expected.to be false }
    end

    context 'ended absence' do
      let(:absence_start_at) { 10.days.ago }
      let(:absence_end_at) { 1.day.ago }
      let(:users) { [user] }

      it { is_expected.to be false }
    end

    context 'currently absent' do
      let(:absence_start_at) { 10.days.ago }
      let(:absence_end_at) { 5.days.since }
      let(:users) { [user] }

      it { is_expected.to be true }
    end
  end
end
