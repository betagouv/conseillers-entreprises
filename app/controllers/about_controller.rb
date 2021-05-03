class AboutController < PagesController
  def cgu; end

  def mentions_d_information; end

  def mentions_legales; end

  def accessibilite; end

  def comment_ca_marche
    @institutions = Rails.cache.fetch("institutions-#{Institution.maximum(:updated_at)}") do
      institutions = Institution.where(show_on_list: true).pluck(:name).sort
      institutions.each_slice((institutions.count.to_f / 4).ceil).to_a
    end
    @faq = [
      {
        question: 'Comment fonctionne le service public Place des Entreprises ?',
        answer: "<ol>\
          <li>Vous choisissez un sujet et déposez votre demande avec quelques éléments de contexte.</li>\
          <li>Nous identifions automatiquement le(s) conseiller(s) compétent(s) pour vous aider sur votre territoire, parmi tous les partenaires du service (administrations, collectivités, organismes publics et parapublics).</li>\
          <li>Le(s) conseiller(s) notifié(s) vous rappelle et vous accompagne en fonction de votre situation.</li>\
        </ol>"
      },
      {
        question: 'Qui sont les conseillers de Place des Entreprises ?',
        answer: "Les conseillers du service Place des Entreprises sont des agents des administrations, des collectivités, des organismes publics et parapublics chargés d’accompagner les entreprises. <br><br> \
        Le service compte aujourd’hui plus de 1 000 conseillers par région, au sein de 50 partenaires différents. Pour des difficultés financières par exemple, en fonction de votre demande, vous pourrez être aidé par un conseiller de la Banque de France, de la Chambre de commerce et d’industrie, de la Chambre des métiers et de l’artisanat, de la Direccte, de votre intercommunalité et/ou de votre Région."
      },
      {
        question: 'Quelles sont les aides proposées par Place des Entreprises ?',
        answer: "En fonction de votre problématique, les conseillers peuvent vous proposer une aide financière, vous apporter un conseil personnalisé, un renseignement ou un accompagnement technique grâce à leur expertise."
      },
      {
        question: 'Pourquoi ce service est-il gratuit ?',
        answer: "Le service de mise en relation avec le bon conseiller est totalement gratuit et financé par le Ministère de l’Économie et Ministère du Travail. <br><br> \
        L’essentiel des accompagnements ensuite proposés par les conseillers sont gratuits, à l’exception des accompagnements techniques sur la durée, principalement réalisés par les chambres consulaires. Après échange avec un conseiller, vous êtes libre de poursuivre ou non un accompagnement. <br><br> \
        Par exemple, des prestations techniques pour la création d’un site internet ou la réduction de votre consommation d’énergie sont payantes, mais à des prix attractifs grâce au soutien financier de l’État ou des collectivités territoriales, dans le cadre de politiques publiques prioritaires."
      }
    ]
  end
end
