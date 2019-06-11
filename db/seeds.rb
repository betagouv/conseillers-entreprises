# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Populate the Home page
Landing.create({
  slug: 'recrutement-formation',
  title: 'Recruter ou former vos salariés',
  subtitle: 'Trouver des candidats, identifier la bonne formation, s’informer sur des aides à l’embauche, contrat de professionalisation ou d’apprentissage…',
  button: 'Échanger avec le bon interlocuteur',
  logos: 'dirrecte, cci, cma, agefiph, cap-emploi',
  featured_on_home: true,
  home_title: 'Recruter ou former vos salariés',
  home_description: 'Trouver des candidats, identifier la bonne formation, s’informer sur les aides à l’embauche, contrat de professionnalisation ou d’apprentissage…',
  home_sort_order: 1,
  landing_topics_attributes: [
    {
      title: 'Recrutez ou formez un salarié',
      description: 'Estimer le coût d’une embauche, trouver des candidats, identifier la bonne formation, s’informer sur les aides à l’embauche, contrat de professionnalisation ou d’apprentissage…'
    },
    {
      title: 'Organisez le travail dans votre entreprise',
      description: 'Accompagnement sur la gestion du temps de travail, la GPEC, les fiches de poste, les évaluations annuelles, l’amélioration des conditions de travail…'
    }
  ]
})
Landing.create({
  slug: 'developpement-commercial',
  title: 'Patrons de TPE et PME, vous souhaitez développer votre activité commerciale ?',
  subtitle: 'Échangez gratuitement avec le bon interlocuteur public selon votre demande.',
  button: 'Échanger avec le bon interlocuteur',
  logos: 'dirrecte, cci, cma, agefiph, cap-emploi',
  featured_on_home: true,
  home_title: 'Développer votre activité commerciale',
  home_description: 'Diversifier votre activité, trouver de nouveaux clients, s’étendre à l’international, rejoindre un club d’entreprises…',
  home_sort_order: 2,
  landing_topics_attributes: [
    {
      title: 'Diversifiez votre activité',
      description: 'Développer une nouvelle offre de produits, de nouveaux services ou une activité complémentaire…'
    },
    {
      title: 'Trouvez de nouveaux clients',
      description: 'Faire un point sur votre stratégie commerciale, vendre par internet, rejoindre un club d’entreprises…'
    },
    {
      title: 'Étendez-vous à l’international',
      description: 'Evaluer votre capacité à exporter, sélectionner des marchés cibles, initier un volontariat international en entreprise,  accompagnement pour les formalités administratives…'
    }
  ]
})

# Fallback landing page
Landing.create({
  slug: 'contactez-nous',
  title: 'Patrons de TPE et PME, plus de 2 000 aides et accompagnements publics existent pour vous aider à grandir ou surmonter une difficulté.',
  subtitle: 'Échangez gratuitement avec le bon interlocuteur public selon votre demande.',
  button: nil,
  logos: 'dirrecte, cci, cma, agefiph, cap-emploi',
  featured_on_home: true,
  home_title: nil,
  home_description: nil,
  home_sort_order: nil,
  landing_topics_attributes: []
})
