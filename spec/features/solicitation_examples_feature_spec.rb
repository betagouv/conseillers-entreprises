require 'rails_helper'

describe 'Solicitation examples below the form' do
  let(:landing) { create :landing, slug: 'accueil' }
  let(:landing_subject) { create :landing_subject, slug: slug }
  let(:slug) { 'reduction-impots' }

  before { visit "/aide-entreprise/#{landing.slug}/demande/#{landing_subject.slug}" }

  def page_schemas
    page.all('script[type="application/ld+json"]', visible: false)
      .flat_map { |script| JSON.parse(script.native.text).fetch('@graph', []) }
  end

  context 'with a subject that has examples' do
    it 'shows every example as a visible quote under its own heading' do
      expect(page).to have_css('h2', text: 'Exemples d’entreprises accompagnées par le service sur leurs questions fiscales')
      expect(page).to have_css('figure.fr-quote blockquote', count: 30)
      expect(page).to have_css('h3', text: 'Courtage grossiste - Crédit d’impôt famille')
      expect(page).to have_css('blockquote', text: 'Mon entreprise a une activité de courtage grossiste.')
      expect(page).to have_no_css('.fr-accordion')
    end

    it 'keeps the line breaks of each request' do
      first_quote = page.first('figure.fr-quote blockquote p')

      expect(first_quote.native.inner_html).to start_with("Bonjour,\n<br>Mon entreprise a une activité de courtage grossiste.")
    end

    it 'invites to submit a request after each example' do
      expect(page).to have_css('form#solicitation-form')
      expect(page).to have_css('p', text: 'Une question sur le même sujet ? Un conseiller vous rappelle sous 5 jours.', count: 30)
      expect(page).to have_link('Déposer une demande', href: '#solicitation-form', count: 30)
    end

    it 'exposes the examples as structured data, not as reviews' do
      example_list = page_schemas.find { |schema| schema['@id'].to_s.end_with?('#solicitation-examples') }

      expect(example_list).to include('@type' => 'ItemList', 'numberOfItems' => 30)
      expect(page_schemas.pluck('@type')).not_to include('Review')
    end
  end

  context 'with a subject that has no examples' do
    let(:slug) { 'sujet-sans-exemple' }

    it 'hides the section' do
      expect(page).to have_no_css('#solicitation-examples-title')
      expect(page_schemas.pluck('@id')).not_to include(a_string_ending_with('#solicitation-examples'))
    end
  end

  context 'when the form is embedded in an iframe' do
    let(:landing) { create :landing, integration: :iframe }

    it 'hides the section' do
      expect(page).to have_no_css('#solicitation-examples-title')
    end
  end
end
