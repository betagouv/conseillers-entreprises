require 'rails_helper'

describe Stats::Filters::Matches do
  let(:query) { Match.all }
  let(:open_struct_graph) { OpenStruct.new }
  let!(:match_outside) { create :match }

  describe 'territories_filter' do
    let(:territory) { create :territory, :region }
    let(:commune) { create :commune, territories: [territory] }
    let(:need_inside) { create :need, diagnosis: create(:diagnosis, facility: create(:facility, commune: commune)) }
    let!(:match_inside) { create :match, need: need_inside }

    subject { described_class.new(query, open_struct_graph).send(:territories_filter, territory) }

    it { is_expected.to eq [match_inside] }
  end

  describe 'antenne_or_institution_filter' do
    let(:institution) { create :institution }
    let(:regional_antenne) { create :antenne, :regional, institution: institution }
    let(:expert_regional_antenne) { create :expert, antenne: regional_antenne }
    let!(:match_regional_antenne) { create :match, need: create(:need), expert: expert_regional_antenne }
    let(:local_antenne) { create :antenne, :local, institution: institution, parent_antenne: regional_antenne }
    let(:expert_local_antenne) { create :expert, antenne: local_antenne }
    let!(:match_local_antenne) { create :match, need: create(:need), expert: expert_local_antenne }

    subject { described_class.new(query, open_struct_graph).send(:antenne_or_institution_filter, antenne_or_institution, with_agglomerate_data) }

    context 'regional antenne only' do
      let(:antenne_or_institution) { regional_antenne }
      let(:with_agglomerate_data) { false }

      it { is_expected.to match_array match_regional_antenne }
    end

    context 'regional antenne with locales' do
      let(:antenne_or_institution) { regional_antenne }
      let(:with_agglomerate_data) { true }

      it { is_expected.to contain_exactly(match_regional_antenne, match_local_antenne) }
    end

    context 'local antenne' do
      let(:antenne_or_institution) { local_antenne }
      let(:with_agglomerate_data) { false }

      it { is_expected.to match_array match_local_antenne }
    end

    context 'institution' do
      let(:antenne_or_institution) { institution }
      let(:with_agglomerate_data) { false }

      it { is_expected.to contain_exactly(match_regional_antenne, match_local_antenne) }
    end
  end

  describe 'subject_filter' do
    let(:a_subject) { create :subject }
    let!(:match_inside) { create :match, subject: a_subject }

    subject { described_class.new(query, open_struct_graph).send(:subject_filter, a_subject) }

    it { is_expected.to eq [match_inside] }
  end

  describe 'integration_filter' do
    let(:integration) { :iframe }
    let(:need_inside) do
      create :need, solicitation: create(:solicitation, landing: create(:landing, integration: integration, partner_url: 'https://www.example.com'))
    end
    let!(:match_inside) { create :match, need: need_inside }

    subject { described_class.new(query, open_struct_graph).send(:integration_filter, integration) }

    it { is_expected.to eq [match_inside] }
  end

  describe 'iframe_filter' do
    let(:iframe) { create(:landing, iframe_category: :themes) }
    let(:need_inside) { create :need, solicitation: create(:solicitation, landing: iframe) }
    let!(:match_inside) { create :match, need: need_inside }

    subject { described_class.new(query, open_struct_graph).send(:iframe_filter, iframe.id) }

    it { is_expected.to eq [match_inside] }
  end

  describe 'theme_filter' do
    let(:theme) { create :theme }
    let!(:match_inside) { create :match, subject: create(:subject, theme: theme) }

    subject { described_class.new(query, open_struct_graph).send(:theme_filter, theme) }

    it { is_expected.to eq [match_inside] }
  end

  describe 'mtm_campaign_filter' do
    let(:mtm_campaign) { 'campaign' }
    let(:need_inside) { create :need, solicitation: create(:solicitation, form_info: { mtm_campaign: mtm_campaign }) }
    let!(:match_inside) { create :match, need: need_inside }

    subject { described_class.new(query, open_struct_graph).send(:mtm_campaign_filter, mtm_campaign) }

    it { is_expected.to eq [match_inside] }
  end

  describe 'mtm_kwd_filter' do
    let(:mtm_kwd) { 'kwd' }
    let(:need_inside) { create :need, solicitation: create(:solicitation, form_info: { mtm_kwd: mtm_kwd }) }
    let!(:match_inside) { create :match, need: need_inside }

    subject { described_class.new(query, open_struct_graph).send(:mtm_kwd_filter, mtm_kwd) }

    it { is_expected.to eq [match_inside] }
  end
end
