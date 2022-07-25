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
    before { visit "/besoins/#{a_match.need.id}" }

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

  describe '/contacts/:id/historique-des-besoins' do
    let(:visitee) { create :contact, :with_phone_number }
    let(:solicitation_1) { create :solicitation, email: visitee.email }
    let(:diagnosis_1) { create :diagnosis_completed, visitee: visitee, solicitation: solicitation_1 }
    let!(:need_1) { create :need, diagnosis: diagnosis_1 }
    let!(:match_1) { create :match, expert: current_user.experts.first, need: need_1, status: :taking_care }
    let(:solicitation_2) { create :solicitation, email: visitee.email }
    let(:diagnosis_2) { create :diagnosis_completed, visitee: visitee, solicitation: solicitation_2 }
    let!(:need_2) { create :need, diagnosis: diagnosis_2 }
    let!(:match_2) { create :match, expert: current_user.experts.first, need: need_2, status: :done }

    before { visit "/contacts/#{visitee.id}/historique-des-besoins" }

    it { is_expected.to be_accessible }
  end
end
