require 'rails_helper'

describe SeoHelper do
  describe '#temoignage_article_schema' do
    subject(:schema) { helper.temoignage_article_schema(temoignage: temoignage, image: '/temoignages_experts/banque_de_france.jpeg') }

    let(:temoignage) do
      TemoignagesExperts::Temoignage.new(
        title: 'Comment la Banque de France vous accompagne dès les premières inquiétudes de trésorerie ?',
        subtitle: 'J’écoute les chefs d’entreprise pour les orienter au mieux.',
        institution: 'Banque de France',
        expert: 'Dupond Dupont',
        publication_date: Date.new(2026, 6, 11),
        initial_publication_date: Date.new(2024, 12, 5),
        landing_subject: 'tresorerie',
        mtm_kwd: 'article-bdf',
        voir_aussi: []
      )
    end

    it 'is an Article carrying the testimonial content' do
      expect(schema).to include(
        '@type': 'Article',
        headline: 'Comment la Banque de France vous accompagne dès les premières inquiétudes de trésorerie ?',
        description: 'J’écoute les chefs d’entreprise pour les orienter au mieux.',
        image: '/temoignages_experts/banque_de_france.jpeg',
        inLanguage: 'fr-FR'
      )
    end

    it 'exposes the initial and last publication dates as datetimes with the Paris timezone offset' do
      expect(schema[:datePublished]).to eq('2024-12-05T00:00:00+01:00')
      expect(schema[:dateModified]).to eq('2026-06-11T00:00:00+02:00')
    end

    it 'is authored and published by the editorial organization, not the interviewee' do
      expect(schema[:author]).to eq('@id': "#{helper.root_url}#organization")
      expect(schema[:publisher]).to eq('@id': "#{helper.root_url}#organization")
    end

    it 'is about the interviewed advisor as a Person working for the institution' do
      expect(schema[:about]).to include(
        '@type': 'Person',
        name: 'Dupond Dupont',
        worksFor: { '@type': 'GovernmentOrganization', name: 'Banque de France' }
      )
    end

    it 'is also about the shared government service node of the graph' do
      expect(schema[:about]).to include('@id': "#{helper.root_url}#service")
    end
  end
end
