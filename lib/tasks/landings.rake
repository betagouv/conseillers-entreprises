namespace :landings do
  task seed: :environment do
    landings = [
      {
        slug: 'a-qui-s-adresser',
        button: 'Oui, je veux être appelé',
        subtitle: 'Essayez Réso, l’expert public compétent vous appelle.',
        title: 'Chef d’entreprise, vous avez un projet ou une difficulté mais vous ne savez à qui vous adresser ?',
      },
      {
        slug: 'aide-publique',
        button: 'Oui aidez-moi à trouver la bonne aide publique',
        subtitle: 'Chef d’entreprise, essayez Réso, on fait le tri pour vous !',
        title: 'Savez-vous qu’il existe plus de 2000 aides publiques ?',
      },
      {
        slug: 'cession',
        button: 'Oui, aidez-moi à céder mon entreprise',
        subtitle: 'Essayez Reso, le service public rapide et gratuit pour la transmission/reprise d’entreprise.',
        title: 'Vous voulez céder votre entreprise ?',
      },
      {
        slug: 'difficultes-financieres',
        button: 'Oui, aidez-moi à surmonter mes difficultés financières',
        subtitle: 'Essayez Réso, le service public rapide et gratuit pour trouver des solutions financières.',
        title: 'Votre entreprise rencontre des difficultés financières ?',
      },
      {
        slug: 'investissement',
        button: 'Oui, aidez-moi à financer mes projets',
        subtitle: 'Essayez Réso, le service public rapide et gratuit pour trouver des solutions financières.',
        title: 'Chef d’entreprise, vous cherchez des financements pour vos projets ?',
      },
      {
        slug: 'joindre-l-administration',
        button: 'Oui, je veux être appelé',
        subtitle: 'Essayez Réso, l’expert public compétent vous appelle.',
        title: 'Chef d’entreprise, trop compliqué de joindre une administration ?',
      },
      {
        slug: 'reprise',
        button: 'Oui, aidez-moi à trouver une entreprise à reprendre',
        subtitle: 'Essayez Reso, le service public rapide et gratuit pour la transmission/reprise d’entreprise.',
        title: 'Vous cherchez une entreprise à reprendre ?',
      },
      {
        slug: 'strategie-numerique',
        button: 'Oui, aidez-moi à développer ma stratégie numérique',
        subtitle: 'Essayez Réso, le service public rapide et gratuit pour accéder aux experts du numérique.',
        title: 'Chef d’entreprise, besoin d’aide pour votre site internet ?',
      }
    ]

    landings.each do |h|
      Landing.create(h)
    end
  end
end
