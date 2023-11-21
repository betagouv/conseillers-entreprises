require 'rails_helper'

describe Stats::Filters::Solicitations do
  let(:query) { Solicitation.all }
  let!(:solicitation_outside) { create :need }

  describe 'territories_filter' do
    let(:territory) { create :territory, code_region: '01' }
    let(:solicitation_inside) { create :solicitation, code_region: territory.code_region }

    subject { described_class.new(query).send(:territories_filter, territory) }

    it { is_expected.to eq [solicitation_inside] }
  end

  describe 'antenne_or_institution_filter' do
    let(:antenne_or_institution) { create :antenne }
    let(:expert_inside) { create :expert, antenne: antenne_or_institution }
    let!(:need_inside) { create :need, matches: [create(:match, expert: expert_inside)] }

    subject { described_class.new(query).send(:antenne_or_institution_filter, antenne_or_institution) }

    it { is_expected.to eq [need_inside.solicitation] }
  end

  describe 'subject_filter' do
    let(:a_subject) { create :subject }
    let(:landing_subject) { create :landing_subject, subject: a_subject }
    let!(:solicitation_inside) { create :solicitation, landing_subject: landing_subject }

    subject { described_class.new(query).send(:subject_filter, a_subject) }

    it { is_expected.to eq [solicitation_inside] }
  end

  describe 'integration_filter' do
    let(:integration) { :iframe }
    let!(:solicitation_inside) { create :solicitation, landing: create(:landing, integration: integration, partner_url: 'https://www.example.com') }

    subject { described_class.new(query).send(:integration_filter, integration) }

    it { is_expected.to eq [solicitation_inside] }
  end

  describe 'iframe_filter' do
    let(:iframe) { create(:landing, iframe_category: :themes) }
    let!(:solicitation_inside) { create :solicitation, landing: iframe }

    subject { described_class.new(query).send(:iframe_filter, iframe.id) }

    it { is_expected.to eq [solicitation_inside] }
  end

  describe 'theme_filter' do
    let(:theme) { create :theme }
    let(:landing_subject) { create :landing_subject, subject: create(:subject, theme: theme) }
    let!(:solicitation_inside) { create :solicitation, landing_subject: landing_subject }

    subject { described_class.new(query).send(:theme_filter, theme) }

    it { is_expected.to eq [solicitation_inside] }
  end

  describe 'mtm_campaign_filter' do
    let(:mtm_campaign) { 'campaign' }
    let!(:solicitation_inside) { create :solicitation, form_info: { mtm_campaign: mtm_campaign } }

    subject { described_class.new(query).send(:mtm_campaign_filter, mtm_campaign) }

    it { is_expected.to eq [solicitation_inside] }
  end

  describe 'mtm_kwd_filter' do
    let(:mtm_kwd) { 'kwd' }
    let(:solicitation_inside) { create :solicitation, form_info: { mtm_kwd: mtm_kwd } }

    subject { described_class.new(query).send(:mtm_kwd_filter, mtm_kwd) }

    it { is_expected.to eq [solicitation_inside] }
  end
end
