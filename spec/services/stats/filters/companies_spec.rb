require 'rails_helper'

describe Stats::Filters::Companies do
  let(:query) { Company.all }
  let!(:company_outside) { create :company }

  describe 'territories_filter' do
    let(:territory) { create :territory }
    let(:commune) { create :commune, territories: [territory] }
    let!(:company_inside) { create :company, facilities: [create(:facility, commune: commune)] }

    subject { described_class.new(query).send(:territories_filter, territory) }

    it { is_expected.to eq [company_inside] }
  end

  describe 'antenne_or_institution_filter' do
    let(:antenne_or_institution) { create :antenne }
    let(:expert_inside) { create :expert, antenne: antenne_or_institution }
    let!(:need_inside) { create :need, matches: [create(:match, expert: expert_inside)] }

    subject { described_class.new(query).send(:antenne_or_institution_filter, antenne_or_institution) }

    it { is_expected.to eq [need_inside.company] }
  end

  describe 'subject_filter' do
    let(:a_subject) { create :subject }
    let!(:diagnosis) { create :diagnosis, needs: [create(:need)], solicitation: solicitation }
    let(:solicitation) { create :solicitation, landing_subject: create(:landing_subject, subject: a_subject) }

    subject { described_class.new(query).send(:subject_filter, a_subject) }

    it { is_expected.to eq [diagnosis.company] }
  end

  describe 'integration_filter' do
    let(:integration) { :iframe }
    let(:diagnosis_inside) do
  create :diagnosis, needs: [create(:need)],
                         solicitation: create(:solicitation, landing: create(:landing, integration: integration, partner_url: 'https://www.example.com'))
end

    subject { described_class.new(query).send(:integration_filter, integration) }

    it { is_expected.to eq [diagnosis_inside.company] }
  end

  describe 'iframe_filter' do
    let(:iframe) { create(:landing, iframe_category: :themes) }
    let!(:diagnosis_inside) { create :diagnosis, solicitation: create(:solicitation, landing: iframe) }

    subject { described_class.new(query).send(:iframe_filter, iframe.id) }

    it { is_expected.to eq [diagnosis_inside.company] }
  end

  describe 'theme_filter' do
    let(:theme) { create :theme }
    let!(:diagnosis_inside) { create :diagnosis, solicitation: create(:solicitation, landing_subject: create(:landing_subject, subject: create(:subject, theme: theme))) }

    subject { described_class.new(query).send(:theme_filter, theme) }

    it { is_expected.to eq [diagnosis_inside.company] }
  end

  describe 'mtm_campaign_filter' do
    let(:mtm_campaign) { 'campaign' }
    let!(:diagnosis_inside) { create :diagnosis, solicitation: create(:solicitation, form_info: { mtm_campaign: mtm_campaign }) }

    subject { described_class.new(query).send(:mtm_campaign_filter, mtm_campaign) }

    it { is_expected.to eq [diagnosis_inside.company] }
  end

  describe 'mtm_kwd_filter' do
    let(:mtm_kwd) { 'kwd' }
    let!(:diagnosis_inside) { create :diagnosis, solicitation: create(:solicitation, form_info: { mtm_kwd: mtm_kwd }) }

    subject { described_class.new(query).send(:mtm_kwd_filter, mtm_kwd) }

    it { is_expected.to eq [diagnosis_inside.company] }
  end
end
