# frozen_string_literal: true

require 'rails_helper'

describe QwantApiService do
  describe 'results_for_query' do
    let(:url) { "https://api.qwant.com/egp/search/web?q=#{query}" }
    let(:query) { '123456789' }

    let(:qwant_json) do
      {
        'data' => {
          'result' => {
            'items' => [
              {
                'title' => 'Rejoins <b>OCTO</b>',
                'favicon' => '//s.qwant.com/fav/o/c/rejoins_octo_com.ico',
                'url' => 'http =>//rejoins.octo.com/',
                'source' => 'rejoins.<b>octo</b>.com',
                'desc' => 'Nos tribus - Devenir un <b>Octo</b> - Nos offres d\'emploi - Nos offres de stage.',
                '_id' => '1234567890',
                'position' => 8
              }
            ]
          }
        }
      }
    end

    before do
      allow(described_class).to receive(:open).with(url) { File }
      allow(File).to receive(:read) { qwant_json }
      allow(JSON).to receive(:parse).with(qwant_json)
    end

    after do
      expect(described_class).to have_received(:open)
      expect(File).to have_received(:read)
      expect(JSON).to have_received(:parse)
    end

    it { described_class.results_for_query query }
  end
end
