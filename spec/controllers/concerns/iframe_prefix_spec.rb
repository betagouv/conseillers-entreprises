# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IframePrefix do
  describe 'set_solicitation_form_info' do
    let(:controller) { described_class }

    subject { described_class.set_solicitation_form_info(session_params, query_params) }

    context 'query_params is not present' do
      let(:session_params) { {} }
      let(:query_params) { nil }

      xit { is_expected.to be_nil }
    end

    context 'there is no campaign before' do
      let(:session_params) { { gclid: 'gclid' } }
      let(:query_params) { { pk_campaign: 'pk_campaign', pk_kwd: 'pk_kwd' } }

      xit { is_expected.to eq(gclid: 'gclid', pk_campaign: 'pk_campaign', pk_kwd: 'pk_kwd') }
    end

    context 'a campaign pk already present' do
      let(:session_params) { { pk_campaign: 'pk_campaign', pk_kwd: 'pk_kwd', gclid: 'gclid' } }
      let(:query_params) { { mtm_campaign: 'mtm_campaign', pk_kwd: 'pk_kwd' } }

      xit 'keep the last campaign' do
        is_expected.to eq(gclid: 'gclid', mtm_campaign: 'mtm_campaign', pk_kwd: 'pk_kwd')
      end
    end
  end
end
