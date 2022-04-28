# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'needs/show', type: :view do
  login_user
  let(:need) { create :need_with_matches, status: :quo }
  let(:matches) { need.matches }
  let!(:taken_care_match) { create :match, need: need, status: :taking_care }

  let(:assignments) do
    enable_pundit(view, current_user)
    assign(:need, need)
    assign(:matches, matches)
    render
  end

  context 'for expert user' do
    let!(:a_match) { create :match, expert: current_user.experts.first, need: need }

    describe 'display page' do
      before { assignments }

      it('displays subject title') { expect(rendered).to have_selector('h1', text: need.subject.label) }
      it('display other experts matches') { expect(rendered).to have_selector('#all-experts', text: matches.first.expert.full_name) }
      it('display new feedback form') { expect(rendered).to have_selector('.feedbacks-form', text: I18n.t('feedbacks.form.title')) }
      it('have form for additional experts') { expect(render).not_to have_selector('.additional-experts', count: 1) }
      it('has form for close matches') { expect(render).not_to have_selector(".details--dropdown", count: 1) }
    end

    describe 'displays page without solicitation' do
      before { assignments }

      it('displays diagnosis content') { expect(rendered).to match need.diagnosis.content }
    end

    describe 'displays page with solicitation' do
      let(:solicitation) { create :solicitation, diagnosis: need.diagnosis }

      before { assignments }

      it('displays solicitation description') { expect(rendered).to match solicitation.description }
    end

    describe 'status quo' do
      before { assignments }

      it('displays action for match') { expect(render).to have_selector('#match-actions', text: I18n.t('needs.match_actions.can_you_help', company: need.company)) }
    end

    describe 'status taking_care' do
      before do
        a_match.update status: :taking_care
        assignments
      end

      it('displays action title') { expect(render).to match 'C‘est à vous de jouer' }
      it('displays actions choices') { expect(render).to have_selector('div.close-need-box', count: 3) }
    end

    describe 'status done' do
      before do
        a_match.update status: :done
        assignments
      end

      it('displays action for match') { expect(render).to match I18n.t('needs.match_actions.its_done') }
    end

    describe 'status done_not_reachable' do
      before do
        a_match.update status: :done_not_reachable
        assignments
      end

      it('displays action for match') { expect(render).to match I18n.t('needs.match_actions.its_done') }
    end

    describe 'status done_no_help' do
      before do
        a_match.update status: :done_no_help
        assignments
      end

      it('displays action for match') { expect(render).to match I18n.t('needs.match_actions.its_done') }
    end

    describe 'status not_for_me' do
      before do
        a_match.update status: :not_for_me
        assignments
      end

      it('displays action for match') { expect(render).to match I18n.t('needs.match_actions.need_canceled') }
    end
  end

  context 'for admin' do
    before do
      current_user.user_rights.create(category: 'admin')
      assignments
    end

    it('displays subject title') { expect(rendered).to match(need.subject.label) }
    it('not displays action for match') { expect(render).not_to have_selector('#match-actions') }
    it('has form for additional experts') { expect(render).to have_selector('.additional-experts', count: 1) }
    it('has form for close matches') { expect(render).to have_selector(".details--dropdown", count: 2) }
  end
end
