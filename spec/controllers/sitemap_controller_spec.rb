require 'rails_helper'

RSpec.describe SitemapController do
  before { create_home_landing }

  describe 'GET #sitemap' do
    let(:landing) { create(:landing) }
    let(:landing_subject) { create(:landing_subject) }

    context 'HTML format' do
      it do
        get :sitemap
        expect(response).to be_successful
      end
    end

    context 'XML format' do
      it do
        get :sitemap, format: :xml
        expect(response).to be_successful
      end
    end
  end
end
