# frozen_string_literal: true

require 'rails_helper'

describe 'needs', :js, type: :feature do
  before { create_home_landing }

  login_user
  let(:expert) { create :expert, users: [current_user] }

  subject { page }

  describe '/besoins/boite_de_reception' do
    before do
      create_list :match, 2, expert: expert
      visit '/besoins/boite_de_reception'
    end

    it { is_expected.to be_accessible }
  end

  describe '/besoins/:need' do
    before { visit "/besoins/#{a_match.need.id}" }

    context 'match quo' do
      let(:a_match) { create :match, expert: expert, status: :quo }

      it { is_expected.to be_accessible }
    end

    context 'match taking_care' do
      let(:a_match) { create :match, expert: expert, status: :taking_care }

      it { is_expected.to be_accessible }
    end

    context 'match done' do
      let(:a_match) { create :match, expert: expert, status: :done }

      it { is_expected.to be_accessible }
    end

    context 'match not_for_me' do
      let(:a_match) { create :match, expert: expert, status: :not_for_me }

      it { is_expected.to be_accessible }
    end
  end

  describe '/contacts/:id/historique-des-besoins' do
    let(:visitee) { create :contact, :with_phone_number }
    let(:solicitation_1) { create :solicitation, email: visitee.email }
    let(:diagnosis_1) { create :diagnosis_completed, visitee: visitee, solicitation: solicitation_1 }
    let!(:need_1) { create :need, diagnosis: diagnosis_1 }
    let!(:match_1) { create :match, expert: expert, need: need_1, status: :taking_care }
    let(:solicitation_2) { create :solicitation, email: visitee.email }
    let(:diagnosis_2) { create :diagnosis_completed, visitee: visitee, solicitation: solicitation_2 }
    let!(:need_2) { create :need, diagnosis: diagnosis_2 }
    let!(:match_2) { create :match, expert: expert, need: need_2, status: :done }

    before { visit "/contacts/#{visitee.id}/historique-des-besoins" }

    it { is_expected.to be_accessible }
  end

  describe '/besoins/:id' do
    let(:solicitation) { create :solicitation, :with_diagnosis }
    let(:need) { create :need, advisor: current_user, diagnosis: solicitation.diagnosis }
    let(:a_match) { create :match, expert: expert, need: need }
    let(:another_match) { create :match, need: need }
    let(:feedback) { create :feedback, :for_need, feedbackable: need }

    before do
      solicitation
      need
      a_match
      another_match
      feedback
    end

    describe 'with status_quo need' do
      before do
        need.update(status: :quo)
        visit "/besoins/#{need.id}"
      end

      it { is_expected.to be_accessible }
    end

    describe 'with status_taking_care need' do
      before do
        need.update(status: :taking_care)
        visit "/besoins/#{need.id}"
      end

      it { is_expected.to be_accessible }
    end

    describe 'with status_not_for_me need' do
      before do
        need.update(status: :not_for_me)
        visit "/besoins/#{need.id}"
      end

      it { is_expected.to be_accessible }
    end
  end
end
