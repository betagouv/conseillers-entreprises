# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API Place des Entreprises V1',
        description: "## Bienvenue sur la documentation de l'API de Place des Entreprises
        \nCette API permet à une organisation de proposer un formulaire de dépôt de besoin d'entreprise connecté à Place des Entreprises sur son propre site internet.
        \nConcrètement, cette API permet de :
        \n- récupérer la liste des pages d'atterrisage, thèmes et sujets autorisés pour l'organisation concernée,
        \n- d'envoyer à Place des Entreprises un besoin
        \n### Limite des requêtes
        \nLe serveur accepte un maximum de 300 appels  par 5 minutes.
        ",
        version: '1.0.0',
        contact: {
          name: 'Équipe technique',
          email: 'tech@place-des-entreprises.beta.gouv.fr'
        }
      },
      tags: [
        { name: 'Page d’atterrissage' },
        { name: 'Thèmes' },
        { name: 'Sujets' },
      ],
      paths: {},
      servers: [
        {
          url: 'https://place-des-entreprises.beta.gouv.fr',
        },
        {
          url: 'https://reso-staging.osc-fr1.scalingo.io',
        },
      ],
      components: {
        schemas: {
          landing: {
            type: :object,
            properties: {
              id: { type: :integer },
              iframe_category: { type: :string },
              title: { type: :string },
              slug: { type: :string },
              partner_url: { type: :string },
              landing_themes: {
                type: :array,
                items: {
                  '$ref': "#/components/schemas/landing_theme"
                }
              }
            },
            required: [ 'id', 'title', 'partner_url' ]
          },
          landing_theme: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              slug: { type: :string },
              description: { type: :string },
              landing_subjects: {
                type: :array,
                items: {
                  '$ref': "#/components/schemas/landing_subject"
                }
              }
            },
            required: [ 'id', 'title' ]
          },
          landing_subject: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              slug: { type: :string },
              description: { type: :string },
              description_explanation: { type: :string },
              requires_siret: { type: :boolean },
              requires_location: { type: :boolean },
              landing_subjects: {
                type: :array,
                items: {
                  '$ref': "#/components/schemas/landing_subject"
                }
              }
            },
            required: [ 'id', 'title', 'slug' ]
          },
          error: {
            type: :object,
            properties: {
              source: { type: :string },
              message: { type: :string }
            }
          }
        },
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            description: "Le jeton vous est fourni après étude de votre demande par Place des Entreprises.
            \nIl doit être placé dans le header '`Authorization: Bearer VOTRE_JETON`'.
            \nSa validité est de 18 mois, renouvelable sur demande."
          }
        }
      },
      security: [
        {
          bearer_auth: []
        }
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml
end
