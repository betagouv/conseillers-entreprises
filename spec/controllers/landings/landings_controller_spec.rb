require 'rails_helper'

RSpec.describe Landings::LandingsController do
  before { create_home_landing }

  describe 'GET #show' do
    context 'existing home landing page' do
      it do
        get :home
        expect(response).to be_successful
      end
    end

    context 'with existing landing' do
      let(:landing) { create :landing }

      it do
        get :show, params: { landing_slug: landing.slug }
        expect(response).to be_successful
      end
    end

    context 'without existing landing' do
      before { ENV['TEST_ERROR_RENDERING'] = 'true' }
      after { ENV['TEST_ERROR_RENDERING'] = 'false' }

      it do
        get :show, params: { landing_slug: 'unknown' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "iframes" do
    let!(:landing_theme) { create :landing_theme, slug: 'theme-cool' }
    let!(:landing_subject) { create :landing_subject, landing_theme: landing_theme, slug: 'yeah-subject' }

    before { landing_theme.landings.push(landing) }

    context 'iframe category' do
      let!(:landing) { create :landing, slug: 'iframe-baby', integration: :iframe, iframe_category: iframe_category }

      context 'iframe_category integral' do
        let(:iframe_category) { :integral }

        it do
          get :show, params: { landing_slug: landing.slug }
          expect(response).to be_successful
        end
      end

      context 'iframe_category themes' do
        let(:iframe_category) { :themes }

        it do
          get :show, params: { landing_slug: landing.slug }
          expect(response).to be_successful
        end
      end

      context 'iframe_category subjects' do
        let(:iframe_category) { :subjects }

        it do
          get :show, params: { landing_slug: landing.slug }
          expect(response).to redirect_to landing_theme_path(landing, landing_theme)
        end
      end

      context 'iframe_category form' do
        let(:iframe_category) { :form }

        it do
          get :show, params: { landing_slug: landing.slug }
          expect(response).to redirect_to new_solicitation_path(landing.slug, landing_subject.slug)
        end
      end
    end

    context 'iframe paused' do
      let!(:landing) { create :landing, slug: 'iframe-baby', integration: :iframe, paused_at: 1.day.ago }

      it do
        get :show, params: { landing_slug: landing.slug }
        expect(response).to redirect_to paused_landing_path(landing)
      end
    end
  end
end
