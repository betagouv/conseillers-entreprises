require 'rails_helper'

RSpec.describe 'companies/needs' do
  login_user
  let(:facility) { create :facility }
  let(:expert) { create :expert, users: [current_user] }
  let(:need) { create :need, matches: build_list(:match, 1, expert: expert) }
  let(:another_need) { create :need, matches: build_list(:match, 1, expert: expert) }
  let(:inaccessible_need) { create :need_with_matches }

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

    it { expect(render).to have_css('h1', text: strip_tags(I18n.t('companies.needs.title_html', company: facility.company.name, siret: facility.siret))) }
  end

  describe 'with only quo needs' do
    before do
      assign(:needs_in_progress, [need])
      assign(:needs_done, [])
      assignments
    end

    it 'shows the need in the quo section' do
      expect(rendered).to have_css('h2', text: I18n.t('companies.needs.needs_in_progress'))
      expect(rendered).to have_no_css('h2', text: I18n.t('companies.needs.needs_done'))
      expect(rendered).to have_css('div.fr-tile', count: 1)
      expect(rendered).to have_link(text: need.subject.label)
    end
  end

  describe 'with only done needs' do
    before do
      assign(:needs_in_progress, [])
      assign(:needs_done, [need, another_need])
      assignments
    end

    it('show the needs in the done section') do
      expect(rendered).to have_css('h2', text: I18n.t('companies.needs.needs_done'))
      expect(rendered).to have_no_css('h2', text: I18n.t('companies.needs.needs_in_progress'))
      expect(rendered).to have_css('div.fr-tile', count: 2)
      expect(rendered).to have_link(text: need.subject.label)
      expect(rendered).to have_link(text: another_need.subject.label)
    end
  end

  describe 'with done and in progress needs' do
    before do
      assign(:needs_in_progress, [need])
      assign(:needs_done, [another_need])
      assignments
    end

    it('shows the need in each section') do
      expect(rendered).to have_css('h2', text: I18n.t('companies.needs.needs_done'))
      expect(rendered).to have_css('h2', text: I18n.t('companies.needs.needs_in_progress'))
      expect(rendered).to have_css('div.fr-tile', count: 2)
      expect(rendered).to have_link(text: need.subject.label)
      expect(rendered).to have_link(text: another_need.subject.label)
    end
  end

  describe 'with inaccessible need' do
    before do
      assign(:needs_in_progress, [need])
      assign(:needs_done, [inaccessible_need])
      assignments
    end

    it('show the inaccessible need as non interactive') do
      expect(rendered).to have_css('h2', text: I18n.t('companies.needs.needs_done'))
      expect(rendered).to have_css('h2', text: I18n.t('companies.needs.needs_in_progress'))
      expect(rendered).to have_css('div.fr-tile', count: 2)
      expect(rendered).to have_link(text: need.subject.label)
      expect(rendered).to have_no_link(text: inaccessible_need.subject.label)
      expect(rendered).to have_text(inaccessible_need.subject.label)
    end
  end
end
