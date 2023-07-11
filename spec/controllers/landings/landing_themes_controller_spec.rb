# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Landings::LandingThemesController do
  describe 'GET #show' do
    let!(:landing) { create :landing, slug: 'accueil', layout: layout }
    let!(:landing_theme) { create :landing_theme, slug: 'environnement' }

    context 'standard landing_theme' do
      let(:layout) { 'multiple_steps' }

      it do
        get :show, params: { landing_slug: landing.slug, slug: landing_theme.slug }
        expect(response).to be_successful
      end
    end

    context 'layout_single_page theme' do
      let(:layout) { 'single_page' }

      context 'no matomo params' do
        it do
          get :show, params: { landing_slug: landing.slug, slug: landing_theme.slug }

          expect(response).to redirect_to landing_path(landing)
        end
      end

      context 'internal navigation' do
        context 'only session params' do
          it do
            p "internal navigation only session params"
            request.session[:solicitation_form_info] = { "pk_campaign" => "pk_c", "pk_kwd" => "pk_k" }
            p ENV['HOST_NAME']
            request.env['HTTP_REFERER'] = ENV['HOST_NAME']
            get :show, params: { landing_slug: landing.slug, slug: landing_theme.slug }

            expect(response).to redirect_to({ controller: "landings/landings", action: "show", landing_slug: landing.slug }.merge({ pk_campaign: 'pk_c', pk_kwd: 'pk_k' }))
          end
        end

        context 'only view params' do
          it do
            get :show, params: { landing_slug: landing.slug, slug: landing_theme.slug, mtm_campaign: 'mtm_c', mtm_kwd: 'mtm_k' }

            expect(response).to redirect_to({ controller: "landings/landings", action: "show", landing_slug: landing.slug }.merge({ mtm_campaign: 'mtm_c', mtm_kwd: 'mtm_k' }))
          end
        end
      end

      context 'coming from external link' do
        context 'only session params' do
          it do
            request.session[:solicitation_form_info] = { "pk_campaign" => "pk_c", "pk_kwd" => "pk_k" }
            get :show, params: { landing_slug: landing.slug, slug: landing_theme.slug }

            expect(response).to redirect_to({ controller: "landings/landings", action: "show", landing_slug: landing.slug })
          end
        end

        context 'double matomo params, mtm recent' do
          it do
            request.session[:solicitation_form_info] = { "pk_campaign" => "pk_c", "pk_kwd" => "pk_k" }
            get :show, params: { landing_slug: landing.slug, slug: landing_theme.slug, mtm_campaign: 'mtm_c', mtm_kwd: 'mtm_k' }

            expect(response).to redirect_to({ controller: "landings/landings", action: "show", landing_slug: landing.slug }.merge({ mtm_campaign: 'mtm_c', mtm_kwd: 'mtm_k' }))
          end
        end

        context 'double matomo params, pk recent' do
          it do
            request.session[:solicitation_form_info] = { "mtm_campaign" => "mtm_c", "mtm_kwd" => "mtm_k" }
            get :show, params: { landing_slug: landing.slug, slug: landing_theme.slug, pk_campaign: 'pk_c', pk_kwd: 'pk_k' }

            expect(response).to redirect_to({ controller: "landings/landings", action: "show", landing_slug: landing.slug }.merge({ pk_campaign: 'pk_c', pk_kwd: 'pk_k' }))
          end
        end
      end
    end
  end
end
