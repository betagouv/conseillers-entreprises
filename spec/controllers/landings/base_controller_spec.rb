# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Landings::BaseController do
  describe 'set_solicitation_form_info' do
    let(:controller) { described_class.new }

    context 'query_params is not present' do
      let(:result) { controller.instance_eval { set_solicitation_form_info({}, nil) } }

      it { expect(result).to be_nil }
    end

    context 'there is no campaign before' do
      let(:result) { controller.instance_eval { set_solicitation_form_info({ gclid: 'gclid' }, { pk_campaign: 'pk_campaign', pk_kwd: 'pk_kwd' }) } }

      it { expect(result).to eq(gclid: 'gclid', pk_campaign: 'pk_campaign', pk_kwd: 'pk_kwd') }
    end

    context 'a campaign pk already present' do
      let(:result) do
  controller.instance_eval do
  set_solicitation_form_info({ pk_campaign: 'pk_campaign', pk_kwd: 'pk_kwd', gclid: 'gclid' },
                             { mtm_campaign: 'mtm_campaign', pk_kwd: 'pk_kwd' })
end
end

      it 'keep the last campaign' do
        expect(result).to eq(gclid: 'gclid', mtm_campaign: 'mtm_campaign', pk_kwd: 'pk_kwd')
      end
    end
  end
end
