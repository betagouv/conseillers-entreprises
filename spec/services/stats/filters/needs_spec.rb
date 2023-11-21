require 'rails_helper'

describe Stats::Filters::Needs do
  let(:query) { Need.all }
  let!(:need_outside) { create :need }

  describe 'territories_filter' do
    let(:territory) { create :territory }
    let(:commune) { create :commune, territories: [territory] }
    let!(:need_inside) { create :need, diagnosis: create(:diagnosis, facility: create(:facility, commune: commune)) }

    subject { described_class.new(query).send(:territories_filter, territory) }

    it { is_expected.to eq [need_inside] }
  end

  describe 'antenne_or_institution_filter' do
    let(:antenne_or_institution) { create :antenne }
    let(:expert_inside) { create :expert, antenne: antenne_or_institution }
    let!(:need_inside) { create :need, matches: [create(:match, expert: expert_inside)] }

    subject { described_class.new(query).send(:antenne_or_institution_filter, antenne_or_institution) }

    it { is_expected.to eq [need_inside] }
  end

  describe 'subject_filter' do
    let(:a_subject) { create :subject }
    let!(:need_inside) { create :need, subject: a_subject }

    subject { described_class.new(query).send(:subject_filter, a_subject) }

    it { is_expected.to eq [need_inside] }
  end

  describe 'integration_filter' do
    let(:integration) { :iframe }
    let!(:need_inside) do
      create :need, solicitation: create(:solicitation, landing: create(:landing, integration: integration, partner_url: 'https://www.example.com'))
    end

    subject { described_class.new(query).send(:integration_filter, integration) }

    it { is_expected.to eq [need_inside] }
  end

  describe 'iframe_filter' do
    let(:iframe) { create(:landing, iframe_category: :themes) }
    let!(:need_inside) { create :need, solicitation: create(:solicitation, landing: iframe) }

    subject { described_class.new(query).send(:iframe_filter, iframe) }

    it { is_expected.to eq [need_inside] }
  end

  describe 'theme_filter' do
    let(:theme) { create :theme }
    let!(:need_inside) { create :need, subject: create(:subject, theme: theme) }

    subject { described_class.new(query).send(:theme_filter, theme) }

    it { is_expected.to eq [need_inside] }
  end

  describe 'mtm_campaign_filter' do
    let(:mtm_campaign) { 'campaign' }
    let!(:need_inside) { create :need, solicitation: create(:solicitation, form_info: { mtm_campaign: mtm_campaign }) }

    subject { described_class.new(query).send(:mtm_campaign_filter, mtm_campaign) }

    it { is_expected.to eq [need_inside] }
  end

  describe 'mtm_kwd_filter' do
    let(:mtm_kwd) { 'kwd' }
    let!(:need_inside) { create :need, solicitation: create(:solicitation, form_info: { mtm_kwd: mtm_kwd }) }

    subject { described_class.new(query).send(:mtm_kwd_filter, mtm_kwd) }

    it { is_expected.to eq [need_inside] }
  end
end
