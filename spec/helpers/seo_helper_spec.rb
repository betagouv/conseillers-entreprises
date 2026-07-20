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

    it 'omits citation when there is no "voir aussi" link' do
      expect(schema).not_to have_key(:citation)
    end

    context 'with "voir aussi" links' do
      let(:temoignage) do
        TemoignagesExperts::Temoignage.new(
          title: 'T', subtitle: 'S', institution: 'Banque de France', expert: 'Dupond Dupont',
          publication_date: Date.new(2026, 6, 11), initial_publication_date: Date.new(2024, 12, 5),
          landing_subject: 'tresorerie', mtm_kwd: 'article-bdf',
          voir_aussi: [
            { name: 'Réagir aux premières difficultés', url: 'https://entreprendre.service-public.gouv.fr/vosdroits/N32550' },
            { name: 'Éviter la cessation des paiements', url: 'https://entreprendre.service-public.gouv.fr/vosdroits/N32476' }
          ]
        )
      end

      it 'cites each "voir aussi" resource as a related CreativeWork' do
        expect(schema[:citation]).to eq([
          { '@type': 'CreativeWork', name: 'Réagir aux premières difficultés', url: 'https://entreprendre.service-public.gouv.fr/vosdroits/N32550' },
          { '@type': 'CreativeWork', name: 'Éviter la cessation des paiements', url: 'https://entreprendre.service-public.gouv.fr/vosdroits/N32476' }
        ])
      end
    end
  end

  describe '#temoignages_list_schema' do
    subject(:schema) { helper.temoignages_list_schema(temoignages: temoignages) }

    let(:temoignages) do
      {
        banque_de_france: TemoignagesExperts::Temoignage.new(
          title: 'Comment la Banque de France vous accompagne ?',
          subtitle: 'J’écoute les chefs d’entreprise.',
          institution: 'Banque de France',
          expert: 'Dupond Dupont',
          publication_date: Date.new(2026, 6, 11),
          initial_publication_date: Date.new(2024, 12, 5),
          landing_subject: 'tresorerie', mtm_kwd: 'a', voir_aussi: []
        ),
        douanes: TemoignagesExperts::Temoignage.new(
          title: 'Comment les douanes accompagnent l’export ?',
          subtitle: 'Nous levons les freins à l’international.',
          institution: 'Douanes',
          expert: 'Jean Valjean',
          publication_date: Date.new(2026, 1, 1),
          initial_publication_date: Date.new(2025, 1, 1),
          landing_subject: 'export', mtm_kwd: 'b', voir_aussi: []
        )
      }
    end

    it 'is an ItemList counting every testimonial' do
      expect(schema).to include('@type': 'ItemList', numberOfItems: 2)
    end

    it 'lists each testimonial as an Article ListItem pointing to its page' do
      first = schema[:itemListElement].first
      expect(first).to include('@type': 'ListItem', position: 1)
      expect(first[:item]).to include(
        '@type': 'Article',
        '@id': "#{helper.temoignages_expert_url(:banque_de_france)}#article",
        url: helper.temoignages_expert_url(:banque_de_france),
        image: helper.image_url('temoignages_experts/banque_de_france.jpeg'),
        headline: 'Comment la Banque de France vous accompagne ?'
      )
    end

    it 'keeps the interview modeling on each item: authored by the org, about the interviewed Person' do
      item = schema[:itemListElement].first[:item]
      expect(item[:author]).to eq('@id': "#{helper.root_url}#organization")
      expect(item[:about]).to include(
        '@type': 'Person',
        name: 'Dupond Dupont',
        worksFor: { '@type': 'GovernmentOrganization', name: 'Banque de France' }
      )
    end
  end
end
