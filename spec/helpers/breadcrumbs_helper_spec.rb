# frozen_string_literal: true

require 'rails_helper'

describe BreadcrumbsHelper do
  describe 'breadcrumbs_landing' do
    subject { helper.breadcrumbs_landing({ landing: landing, landing_theme: landing_theme, landing_subject: landing_subject }, params, title) }

    let(:params) { {} }
    let(:title) { nil }

    context 'internal landing' do
      let(:landing) { create :landing, slug: 'accueil', integration: :intern, layout: :multiple_steps }

      context 'landing_theme page' do
        let(:landing_theme) { create :landing_theme, slug: 'theme-01',title: "Thème 01" }
        let(:landing_subject) { nil }

        it { is_expected.to eq(
          '<li><a class="fr-breadcrumb__link blue" href="/">Accueil</a></li>'\
          '<li><a class="fr-breadcrumb__link" aria-current="page" href="#">Thème 01</a></li>')
        }
      end

      context 'landing_subject page' do
        let(:landing_theme) { create :landing_theme, slug: 'theme-01',title: "Thème 01" }
        let(:landing_subject) { create :landing_subject, title: "Sujet 01" }

        it { is_expected.to eq(
          '<li><a class="fr-breadcrumb__link blue" href="/">Accueil</a></li>'\
          '<li><a class="fr-breadcrumb__link blue" href="/aide-entreprise/accueil/theme/theme-01">Thème 01</a></li>'\
          '<li><a class="fr-breadcrumb__link" aria-current="page" href="#">Sujet 01</a></li>')
        }
      end

      context 'mentions page' do
        let(:landing_theme) { nil }
        let(:landing_subject) { nil }
        let(:title) { 'Mentions légales' }

        it { is_expected.to eq(
          '<li><a class="fr-breadcrumb__link blue" href="/">Accueil</a></li>'\
          '<li><a class="fr-breadcrumb__link" aria-current="page" href="#">Mentions légales</a></li>')
        }
      end
    end

    context 'integral iframe landing' do
      let(:landing) { create :landing, slug: 'iframe-01', integration: :iframe, partner_url: 'example.fr', layout: :multiple_steps, iframe_category: :integral }

      context 'landing page' do
        let(:landing_theme) { nil }
        let(:landing_subject) { nil }

        it { is_expected.to eq(
          '<li><a class="fr-breadcrumb__link blue" href="/aide-entreprise/iframe-01">Place des Entreprises</a></li>')
        }
      end

      context 'landing_theme page' do
        let(:landing_theme) { create :landing_theme, slug: 'theme-01',title: "Thème 01" }
        let(:landing_subject) { nil }

        it { is_expected.to eq(
          '<li><a class="fr-breadcrumb__link blue" href="/aide-entreprise/iframe-01">Place des Entreprises</a></li>'\
          '<li><a class="fr-breadcrumb__link" aria-current="page" href="#">Thème 01</a></li>')
        }
      end

      context 'landing_subject page' do
        let(:landing_theme) { create :landing_theme, slug: 'theme-01',title: "Thème 01" }
        let(:landing_subject) { create :landing_subject, title: "Sujet 01" }

        it { is_expected.to eq(
          '<li><a class="fr-breadcrumb__link blue" href="/aide-entreprise/iframe-01">Place des Entreprises</a></li>'\
          '<li><a class="fr-breadcrumb__link blue" href="/aide-entreprise/iframe-01/theme/theme-01">Thème 01</a></li>'\
          '<li><a class="fr-breadcrumb__link" aria-current="page" href="#">Sujet 01</a></li>')
        }
      end

      context 'mentions page' do
        let(:landing_theme) { nil }
        let(:landing_subject) { nil }
        let(:title) { 'Mentions légales' }

        it { is_expected.to eq(
          '<li><a class="fr-breadcrumb__link blue" href="/aide-entreprise/iframe-01">Place des Entreprises</a></li>'\
          '<li><a class="fr-breadcrumb__link" aria-current="page" href="#">Mentions légales</a></li>')
        }
      end
    end

    context 'subjects iframe landing' do
      let(:landing) { create :landing, slug: 'iframe-01', integration: :iframe, partner_url: 'example.fr', layout: :multiple_steps, iframe_category: :subjects }

      context 'landing_subject page' do
        let(:landing_theme) { create :landing_theme, slug: 'theme-01',title: "Thème 01" }
        let(:landing_subject) { create :landing_subject, title: "Sujet 01" }

        it { is_expected.to eq(
          '<li><a class="fr-breadcrumb__link blue" href="/aide-entreprise/iframe-01">Place des Entreprises</a></li>'\
          '<li><a class="fr-breadcrumb__link" aria-current="page" href="#">Sujet 01</a></li>')
        }
      end
    end
  end
end
