# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'companies/needs.html.haml', type: :view do
  login_user
  let(:facility) { create :facility }
  let(:expert) { current_user.expert }
  let(:need) { create :need_with_matches }
  let(:another_need) { create :need_with_matches }

  let(:assignments) do
    assign(:facility, facility)
    render
  end

  describe 'displays page title' do
    before do
      assign(:needs_in_progress, [])
      assign(:needs_done, [])
      assignments
    end

    it { expect(render).to have_selector('h1', text: I18n.t('companies.needs.title', company: facility.company.name)) }
  end

  describe 'with only quo needs' do
    before do
      assign(:needs_in_progress, [need])
      assign(:needs_done, [])
      assignments
    end

    it('displays title needs in progress') { expect(render).to have_selector('h2', text: I18n.t('companies.needs.needs_in_progress')) }
    it('not displays title needs done') { expect(render).not_to have_selector('h2', text: I18n.t('companies.needs.needs_done')) }
    it('displays needs') { expect(render).to have_selector('div.company-need', count: 1) }
    it('displays need subject') { expect(render).to have_selector('a', text: need.subject.label) }
  end

  describe 'with only done needs' do
    before do
      assign(:needs_in_progress, [])
      assign(:needs_done, [need, another_need])
      assignments
    end

    it('displays title needs done') { expect(render).to have_selector('h2', text: I18n.t('companies.needs.needs_done')) }
    it('not displays title needs in progress') { expect(render).not_to have_selector('h2', text: I18n.t('companies.needs.needs_in_progress')) }
    it('displays needs') { expect(render).to have_selector('div.company-need', count: 2) }
    it('displays first need subject') { expect(render).to have_selector('a', text: need.subject.label) }
    it('displays second need subject') { expect(render).to have_selector('a', text: another_need.subject.label) }
  end

  describe 'with done and in progress needs' do
    before do
      assign(:needs_in_progress, [need])
      assign(:needs_done, [another_need])
      assignments
    end

    it('displays title needs done') { expect(render).to have_selector('h2', text: I18n.t('companies.needs.needs_done')) }
    it('displays title needs in progress') { expect(render).to have_selector('h2', text: I18n.t('companies.needs.needs_in_progress')) }
    it('displays needs') { expect(render).to have_selector('div.company-need', count: 2) }
    it('displays first need subject') { expect(render).to have_selector('a', text: need.subject.label) }
    it('displays second need subject') { expect(render).to have_selector('a', text: another_need.subject.label) }
  end
end
