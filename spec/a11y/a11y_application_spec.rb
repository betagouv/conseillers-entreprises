# frozen_string_literal: true

require 'rails_helper'

describe 'a11y', type: :feature, js: true do
  login_user
  subject { page }

  describe '/besoins/:id' do
    let(:solicitation) { create :solicitation, :with_diagnosis }
    let(:need) { create :need, advisor: current_user, diagnosis: solicitation.diagnosis }
    let(:a_match) { create :match, expert: current_user.experts.first, need: need }
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
