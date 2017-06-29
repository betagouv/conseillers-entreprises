# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Assistance, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :question
      is_expected.to belong_to :institution
      is_expected.to belong_to :expert
      is_expected.to validate_presence_of :title
      is_expected.to validate_presence_of :question
      is_expected.to validate_presence_of :institution
    end
  end

  describe 'validation of institution email' do
    subject(:assistance) { build :assistance, expert: expert, institution: institution }

    context 'without expert' do
      let(:expert) { nil }

      context 'with institution with email' do
        let(:institution) { create :institution, email: 'random@institution.com' }

        it { is_expected.to be_valid }
      end

      context 'with institution without email' do
        let(:institution) { create :institution, email: nil }

        it { is_expected.not_to be_valid }
      end
    end

    context 'with expert' do
      let(:expert) { create :expert }
      let(:institution) { create :institution, email: nil }

      it { is_expected.to be_valid }
    end
  end

  describe 'county and geographic scope' do
    subject(:assistance) { build :assistance, geographic_scope: geographic_scope, county: county }

    context 'county geographic scope' do
      let(:geographic_scope) { :county }

      context 'without county' do
        let(:county) { nil }

        it { is_expected.not_to be_valid }
      end

      context 'with wrong county' do
        let(:county) { 75 }

        it { is_expected.not_to be_valid }
      end

      context 'with authorized county' do
        let(:county) { Assistance::AUTHORIZED_COUNTIES.sample }

        it { is_expected.to be_valid }
      end
    end

    context 'region geographic scope' do
      let(:geographic_scope) { :region }
      let(:county) { nil }

      it { is_expected.to be_valid }
    end
  end

  describe 'scopes' do
    describe 'for_maubeuge' do
      subject { Assistance.for_maubeuge }

      context 'no assistance for maubeuge' do
        before { create :assistance, for_maubeuge: false }

        it do
          create :assistance, for_maubeuge: false

          is_expected.to eq []
        end
      end

      context 'one assistance for maubeuge' do
        it do
          assistance = create :assistance, for_maubeuge: true

          is_expected.to eq [assistance]
        end
      end

      context 'two diagnosis' do
        it do
          assistance1 = create :assistance, for_maubeuge: true
          assistance2 = create :assistance, for_maubeuge: true
          create :assistance, for_maubeuge: false

          is_expected.to match_array [assistance1, assistance2]
        end
      end
    end

    describe 'of_location' do
      subject { Assistance.of_location city_code }

      let(:maubeuge_assistance) { create :assistance, for_maubeuge: true }

      before { create :assistance, for_maubeuge: false }

      context 'no assistance for maubeuge' do
        let(:city_code) { 59_003 }

        it { is_expected.to eq [maubeuge_assistance] }
      end

      # TODO: This test should pass
      # context 'one assistance for maubeuge' do
      #   let(:city_code) { 75_002 }
      #
      #   it { is_expected.to eq [] }
      # end
    end
  end
end
