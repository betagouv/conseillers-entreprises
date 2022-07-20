# frozen_string_literal: true

require 'rails_helper'

describe 'needs', type: :feature, js: true do
  login_user

  subject { page }

  describe '/besoins/boite_de_reception' do
    before do
      create_list :match, 2, expert: current_user.experts.first
      visit '/besoins/boite_de_reception'
    end

    it { is_expected.to be_accessible }
  end

  describe '/besoins/:need' do
    before do
      visit "/besoins/#{a_match.need.id}"
    end

    context 'match quo' do
      let(:a_match) { create :match, expert: current_user.experts.first, status: :quo }

      it { is_expected.to be_accessible }
    end

    context 'match taking_care' do
      let(:a_match) { create :match, expert: current_user.experts.first, status: :taking_care }

      it { is_expected.to be_accessible }
    end

    context 'match done' do
      let(:a_match) { create :match, expert: current_user.experts.first, status: :done }

      it { is_expected.to be_accessible }
    end

    context 'match not_for_me' do
      let(:a_match) { create :match, expert: current_user.experts.first, status: :not_for_me }

      it { is_expected.to be_accessible }
    end
  end
end
