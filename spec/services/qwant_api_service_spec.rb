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
                'url' => 'http://www.internetactu.net/2017/04/13/mais-comment-passe-t-on-des-startups-detat-a-letat-plateforme/',
                'desc' => 'Lentrepreneur Pierre Pezziardi (@ppezziardi) était linvité dune récente matinée organisée par le Liberté Living Lab sur la',
                'date' => 1_492_059_620,
                'domain' => 'internetactu.net',
                '_id' => '342a28b3d4af89967a8415e06c28081d',
                'media' => [
                  {
                    'pict' => {
                      'url' => '//s2.qwant.com/thumbr/0x110/7/9/422b040372a405923aa0e377dca148/b_1_q_0_p_0.jpg?u=http%3A%2F%2Fwww.internetactu.net%2Fwp-content%2Fuploads%2F2017%2F04%2F096-PEZZIARDI_COUV_web-197x300.jpg&q=0&b=1&p=0&a=0',
                      'width' => 0,
                      'height' => 110,
                      'type' => 'image'
                    },
                    'pict_big' => {
                      'url' => '//s2.qwant.com/thumbr/0x240/f/f/ab2f89103a10abb94e9f2cbe327015/b_1_q_0_p_0.jpg?u=http%3A%2F%2Fwww.internetactu.net%2Fwp-content%2Fuploads%2F2017%2F04%2F096-PEZZIARDI_COUV_web-197x300.jpg&q=0&b=1&p=0&a=0',
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
