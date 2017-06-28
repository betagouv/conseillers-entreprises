# frozen_string_literal: true

require 'rails_helper'

describe QwantApiService do
  describe 'results_for_query' do
    let(:url) { "https://api.qwant.com/egp/search/news?q=#{query}" }
    let(:query) { '123456789' }

    let(:qwant_json) do
      {
        'data' => {
          'result' => {
            'items' => [
              {
                'title' => "Mais comment passe-t-on des startups d'Etat à l'Etat plateforme",
                'url' => 'http://www.internetactu.net/2017/04/13/mais-comment-passe-t-on-des-startups/',
                'desc' => 'Lentrepreneur Pierre Pezziardi (@ppezziardi) était linvité dune récente matinée',
                'date' => 1_492_059_620,
                'domain' => 'internetactu.net',
                '_id' => '342a28b3d4af89967a8415e06c28081d',
                'media' => [
                  {
                    'pict' => {
                      'url' => 'pierre.jpg',
                      'width' => 0,
                      'height' => 110,
                      'type' => 'image'
                    },
                    'pict_big' => {
                      'url' => 'pierre_big.jpg',
                      'width' => 0,
                      'height' => 240,
                      'type' => 'image'
                    }
                  }
                ]
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
