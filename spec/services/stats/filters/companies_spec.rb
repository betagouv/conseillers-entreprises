require 'rails_helper'

describe Stats::Filters::Companies do
  let(:query) { Company.all }
  let(:open_struct_graph) { OpenStruct.new }
  let!(:company_outside) { create :company }

  describe 'territories_filter' do
    let(:territory) { create :territory }
    let(:commune) { create :commune, territories: [territory] }
    let!(:company_inside) { create :company, facilities: [create(:facility, commune: commune)] }

    subject { described_class.new(query, open_struct_graph).send(:territories_filter, territory) }

    it { is_expected.to eq [company_inside] }
  end

  describe 'antenne_or_institution_filter' do
    let(:commune1) { create :commune }
    let(:commune2) { create :commune }
    let!(:region) { create :territory, :region, communes: [commune1, commune2] }
    let(:institution) { create :institution }
    let(:regional_antenne) { create :antenne, :regional, institution: institution, communes: [commune1, commune2] }
    let(:expert_regional_antenne) { create :expert, antenne: regional_antenne }
    let!(:need_regional_antenne) { create :need, matches: [create(:match, expert: expert_regional_antenne)] }
    let(:local_antenne) { create :antenne, :local, institution: institution, communes: [commune1] }
    let(:expert_local_antenne) { create :expert, antenne: local_antenne }
    let!(:need_local_antenne) { create :need, matches: [create(:match, expert: expert_local_antenne)] }

    before do
      need_regional_antenne.update(status: 'quo')
      need_local_antenne.update(status: 'quo')
    end

    subject { described_class.new(query, open_struct_graph).send(:antenne_or_institution_filter, antenne_or_institution, with_agglomerate_data) }

    context 'regional antenne only' do
      let(:antenne_or_institution) { regional_antenne }
      let(:with_agglomerate_data) { true }

      it { is_expected.to match_array need_regional_antenne.company }
    end

    context 'regional antenne with locales' do
      let(:antenne_or_institution) { regional_antenne }
      let(:with_agglomerate_data) { false }

      it { is_expected.to contain_exactly(need_regional_antenne.company, need_local_antenne.company) }
    end

    context 'local antenne' do
      let(:antenne_or_institution) { local_antenne }
      let(:with_agglomerate_data) { true }

      it { is_expected.to match_array need_local_antenne.company }
    end

    context 'institution' do
      let(:antenne_or_institution) { institution }
      let(:with_agglomerate_data) { true }

      it { is_expected.to contain_exactly(need_regional_antenne.company, need_local_antenne.company) }
    end
  end

  describe 'subject_filter' do
    let(:a_subject) { create :subject }
    let!(:diagnosis) { create :diagnosis, needs: [create(:need)], solicitation: solicitation }
    let(:solicitation) { create :solicitation, landing_subject: create(:landing_subject, subject: a_subject) }

    subject { described_class.new(query, open_struct_graph).send(:subject_filter, a_subject) }

    it { is_expected.to eq [diagnosis.company] }
  end

  describe 'integration_filter' do
    let(:integration) { :iframe }
    let(:diagnosis_inside) do
  create :diagnosis, needs: [create(:need)],
                         solicitation: create(:solicitation, landing: create(:landing, integration: integration, partner_url: 'https://www.example.com'))
end

    subject { described_class.new(query, open_struct_graph).send(:integration_filter, integration) }

    it { is_expected.to eq [diagnosis_inside.company] }
  end

  describe 'iframe_filter' do
    let(:iframe) { create(:landing, iframe_category: :themes) }
    let!(:diagnosis_inside) { create :diagnosis, solicitation: create(:solicitation, landing: iframe) }

    subject { described_class.new(query, open_struct_graph).send(:iframe_filter, iframe.id) }

    it { is_expected.to eq [diagnosis_inside.company] }
  end

  describe 'theme_filter' do
    let(:theme) { create :theme }
    let!(:diagnosis_inside) { create :diagnosis, solicitation: create(:solicitation, landing_subject: create(:landing_subject, subject: create(:subject, theme: theme))) }

    subject { described_class.new(query, open_struct_graph).send(:theme_filter, theme) }

    it { is_expected.to eq [diagnosis_inside.company] }
  end

  describe 'mtm_campaign_filter' do
    let(:mtm_campaign) { 'campaign' }
    let!(:diagnosis_inside) { create :diagnosis, solicitation: create(:solicitation, form_info: { mtm_campaign: mtm_campaign }) }

    subject { described_class.new(query, open_struct_graph).send(:mtm_campaign_filter, mtm_campaign) }

    it { is_expected.to eq [diagnosis_inside.company] }
  end

  describe 'mtm_kwd_filter' do
    let(:mtm_kwd) { 'kwd' }
    let!(:diagnosis_inside) { create :diagnosis, solicitation: create(:solicitation, form_info: { mtm_kwd: mtm_kwd }) }

    subject { described_class.new(query, open_struct_graph).send(:mtm_kwd_filter, mtm_kwd) }

    it { is_expected.to eq [diagnosis_inside.company] }
  end
end
