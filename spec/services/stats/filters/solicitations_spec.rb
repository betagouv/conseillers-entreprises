require 'rails_helper'

describe Stats::Filters::Solicitations do
  let(:query) { Solicitation.all }
  let(:open_struct_graph) { OpenStruct.new }
  let!(:solicitation_outside) { create :need }

  describe 'territories_filter' do
    let(:territory) { create :territory, code_region: '01' }
    let(:solicitation_inside) { create :solicitation, code_region: territory.code_region }

    subject { described_class.new(query, open_struct_graph).send(:territories_filter, territory) }

    it { is_expected.to eq [solicitation_inside] }
  end

  describe 'antenne_or_institution_filter' do
    let(:institution) { create :institution }
    let(:regional_antenne) { create :antenne, :regional, institution: institution }
    let(:expert_regional_antenne) { create :expert, antenne: regional_antenne }
    let!(:need_regional_antenne) { create :need, matches: [create(:match, expert: expert_regional_antenne)] }

    let(:local_antenne) { create :antenne, :local, institution: institution, parent_antenne: regional_antenne }
    let(:expert_local_antenne) { create :expert, antenne: local_antenne }
    let!(:need_local_antenne) { create :need, matches: [create(:match, expert: expert_local_antenne)] }

    before do
      need_regional_antenne.update(status: 'quo')
      need_local_antenne.update(status: 'quo')
    end

    subject { described_class.new(query, open_struct_graph).send(:antenne_or_institution_filter, antenne_or_institution, with_agglomerate_data) }

    context 'regional antenne only' do
      let(:antenne_or_institution) { regional_antenne }
      let(:with_agglomerate_data) { false }

      it { is_expected.to match_array need_regional_antenne.solicitation }
    end

    context 'regional antenne with locales' do
      let(:antenne_or_institution) { regional_antenne }
      let(:with_agglomerate_data) { true }

      it { is_expected.to contain_exactly(need_regional_antenne.solicitation, need_local_antenne.solicitation) }
    end

    context 'local antenne' do
      let(:antenne_or_institution) { local_antenne }
      let(:with_agglomerate_data) { false }

      it { is_expected.to match_array need_local_antenne.solicitation }
    end

    context 'institution' do
      let(:antenne_or_institution) { institution }
      let(:with_agglomerate_data) { false }

      it { is_expected.to contain_exactly(need_regional_antenne.solicitation, need_local_antenne.solicitation) }
    end
  end

  describe 'subject_filter' do
    let(:a_subject) { create :subject }
    let(:landing_subject) { create :landing_subject, subject: a_subject }
    let!(:solicitation_inside) { create :solicitation, landing_subject: landing_subject }

    subject { described_class.new(query, open_struct_graph).send(:subject_filter, a_subject) }

    it { is_expected.to eq [solicitation_inside] }
  end

  describe 'integration_filter' do
    let(:integration) { :iframe }
    let!(:solicitation_inside) { create :solicitation, landing: create(:landing, integration: integration, url_path: 'https://www.example.com') }

    subject { described_class.new(query, open_struct_graph).send(:integration_filter, integration) }

    it { is_expected.to eq [solicitation_inside] }
  end

  describe 'landing_filter' do
    let(:iframe) { create(:landing, iframe_category: :themes) }
    let!(:solicitation_inside) { create :solicitation, landing: iframe }

    subject { described_class.new(query, open_struct_graph).send(:landing_filter, iframe.id) }

    it { is_expected.to eq [solicitation_inside] }
  end

  describe 'theme_filter' do
    let(:theme) { create :theme }
    let(:landing_subject) { create :landing_subject, subject: create(:subject, theme: theme) }
    let!(:solicitation_inside) { create :solicitation, landing_subject: landing_subject }

    subject { described_class.new(query, open_struct_graph).send(:theme_filter, theme) }

    it { is_expected.to eq [solicitation_inside] }
  end

  describe 'mtm_campaign_filter' do
    let(:mtm_campaign) { 'campaign' }
    let!(:solicitation_inside) { create :solicitation, form_info: { mtm_campaign: mtm_campaign } }

    subject { described_class.new(query, open_struct_graph).send(:mtm_campaign_filter, mtm_campaign) }

    it { is_expected.to eq [solicitation_inside] }
  end

  describe 'mtm_kwd_filter' do
    let(:mtm_kwd) { 'kwd' }
    let(:solicitation_inside) { create :solicitation, form_info: { mtm_kwd: mtm_kwd } }

    subject { described_class.new(query, open_struct_graph).send(:mtm_kwd_filter, mtm_kwd) }

    it { is_expected.to eq [solicitation_inside] }
  end
end
