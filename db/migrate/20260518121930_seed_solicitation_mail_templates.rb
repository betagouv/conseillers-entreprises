class SeedSolicitationMailTemplates < ActiveRecord::Migration[8.1]
  def up
    templates = [
      {
        email_type: 'administrations_collectivites',
        body_html: <<~HTML.strip
          <p>Ce service public est destiné aux TPE et PME. Nous n'avons pas d'expert en mesure de répondre aux problématiques des administrations et des collectivités.</p>
          <p>Liens utiles selon votre démarche :</p>
          <ul>
            <li>pour tous vos projets locaux : <a href="https://aides-territoires.beta.gouv.fr">https://aides-territoires.beta.gouv.fr</a></li>
            <li>pour votre établissement recevant du public (ERP) et son accessibilité : <a href="https://www.ecologie.gouv.fr/politiques-publiques/laccessibilite-etablissements-recevant-du-public-erp">https://www.ecologie.gouv.fr</a></li>
            <li>pour les questions liées à la formation professionnelle des agents : <a href="https://www.service-public.gouv.fr/particuliers/vosdroits/N186">https://www.service-public.gouv.fr</a></li>
            <li>pour les questions liées à l'apprentissage : <a href="https://www.fonction-publique.gouv.fr/devenir-agent-public/lapprentissage-dans-la-fonction-publique">https://www.fonction-publique.gouv.fr</a></li>
          </ul>
        HTML
      },
      {
        email_type: 'carsat',
        body_html: <<~HTML.strip
          <p>Malheureusement, l'organisme compétent, <strong>la CARSAT, n'est pas encore partenaire</strong> du service dans votre région. Nous vous invitons à <strong>la contacter au 3960 pour la retraite</strong> et au <strong>3679 pour les risques professionnels</strong>.</p>
          <p>Liens utiles :</p>
          <ul>
            <li>Retraite : <a href="https://www.lassuranceretraite.fr">www.lassuranceretraite.fr</a></li>
            <li>Subventions liées aux formations ou aux achats de matériels : sur <a href="https://www.ameli.fr/">le site Ameli</a>, choisir le département, puis « Entreprise » dans le bandeau du haut puis le sigle Euros « aides financières TPE PME » dans le bandeau de droite.</li>
            <li>Document unique d'évaluation des risques professionnels (DUERP) :
              <ul>
                <li>Toutes activités : <a href="https://www.inrs.fr/demarche/evaluation-risques-professionnels">https://www.inrs.fr</a></li>
                <li>Spécifique au bâtiment : <a href="https://www.preventionbtp.fr">https://www.preventionbtp.fr</a></li>
              </ul>
            </li>
          </ul>
        HTML
      },
      {
        email_type: 'creation',
        body_html: <<~HTML.strip
          <p>Ce service public ne s'adresse actuellement qu'aux entreprises déjà existantes.</p>
          <p>Vous pouvez vous faire accompagner dans vos démarches de création par des conseillers proches de chez vous :</p>
          <ul>
            <li><strong>pour les activités commerciales :</strong> <a href="https://www.cci.fr/contact">Contacts CCI | CCI - Chambre de commerce et d'industrie (www.cci.fr)</a></li>
            <li><strong>pour les activités artisanales :</strong> <a href="https://www.artisanat.fr/nous-connaitre/contactez-cma">Le portail des Chambres de Métiers et de l'Artisanat en France | Artisanat.fr</a></li>
            <li><strong>pour les activités libérales :</strong> <a href="https://www.arapl.org/mon-arapl">Réseau des ARAPL</a></li>
            <li><strong>pour les activités agricoles :</strong> <a href="https://chambres-agriculture.fr/chambres-dagriculture/nous-connaitre/lannuaire-des-chambres-dagriculture/">L'annuaire des Chambres d'agriculture - Chambres d'agriculture France (chambres-agriculture.fr)</a></li>
          </ul>
          <p>Vous retrouverez toutes les sources de financement possibles pour votre projet sur les sites suivants :</p>
          <ul>
            <li>Bpifrance : <a href="https://bpifrance-creation.fr/boiteaoutils/comment-financer-mon-projet-creation-ou-reprise-dentreprise">Comment financer mon projet de création ou reprise d'entreprise ? | Bpifrance Création (bpifrance-creation.fr)</a></li>
            <li>Banque de France : <a href="https://www.mesquestionsdentrepreneur.fr/creer-entreprise/financer-creation-entreprise">Mes questions d'entrepreneur | Financer ma création (mesquestionsdentrepreneur.fr)</a></li>
            <li>Réseau Initiative : <a href="https://initiative-france.fr/">Accueil - Initiative France</a></li>
            <li>Adie : <a href="https://www.adie.org/">Avec l'Adie : entreprendre c'est possible !</a></li>
          </ul>
        HTML
      },
      {
        email_type: 'employee_labor_law',
        body_html: <<~HTML.strip
          <p>En tant que salarié(e), nous vous invitons à contacter le service de renseignement en droit du travail de la <a href="https://dreets.gouv.fr/">Direction régionale de l'économie, de l'emploi, du travail et des solidarités</a> (DREETS).</p>
          <p>Vous pouvez composer le <b>0806 000 126</b> [prix d'un appel local - pas de surcoût] du lundi au vendredi, de 8h45 à 11h30 et de 13h45 à 16h30.</p>
          <p>Vous trouverez également des informations en droit du travail sur :</p>
          <ul>
            <li><a href="https://www.service-public.gouv.fr/particuliers/vosdroits/N19806">https://www.service-public.gouv.fr/particuliers/vosdroits/N19806</a></li>
            <li><a href="https://code.travail.gouv.fr">https://code.travail.gouv.fr</a></li>
          </ul>
        HTML
      },
      {
        email_type: 'formalites_asso_agri_sci',
        body_html: <<~HTML.strip
          <p>Malheureusement, nous n'avons pas encore d'expert en mesure de répondre à votre problématique dans votre secteur d'activité.</p>
          <p>Nous vous conseillons de contacter :</p>
          <ul>
            <li>Pour les activités agricoles : <a href="https://chambres-agriculture.fr/chambres-dagriculture/nous-connaitre/lannuaire-des-chambres-dagriculture/">L'annuaire des Chambres d'agriculture</a></li>
            <li>Pour les associations : <ul><li><a href="https://www.service-public.gouv.fr/particuliers/vosdroits/R1757">Création d'une association en ligne</a></li><li><a href="https://www.service-public.gouv.fr/particuliers/vosdroits/R37933">Modification d'une association en ligne</a></li><li><a href="https://lannuaire.service-public.gouv.fr/navigation/prefecture">Annuaire des préfectures</a></li></ul></li>
            <li>Pour les agents commerciaux et les SCI : <a href="https://www.infogreffe.fr/rechercher-un-greffe">Moteur de recherche de greffes</a></li>
          </ul>
        HTML
      },
      {
        email_type: 'intermediary',
        body_html: <<~HTML.strip
          <p>Il s'agit d'un service public destiné aux chefs d'entreprises, afin d'aider les petites structures à se développer et à s'adapter.</p>
          <p>Pour la bonne prise en charge de la demande, les conseillers ont besoin du siret de l'entreprise concernée et des coordonnées du dirigeant. Les 40 partenaires publics et parapublics du service ont à cœur <strong>d'échanger directement</strong> avec les entreprises pour répondre au mieux à leur problématique.</p>
          <p>Les demandes déposées par les intermédiaires, quel que soit le mandat, ne sont pas transmises. C'est pourquoi <strong>nous vous invitons à accompagner votre interlocuteur / client</strong> pour qu'il dépose lui-même une demande sur le site.</p>
        HTML
      },
      {
        email_type: 'kbis_extract',
        body_html: <<~HTML.strip
          <p>Si vous rencontrez des difficultés techniques sur le site MonIdenum et <a href="https://monidenum.fr/contact">son support</a>, ce document est également disponible pour les activités commerciales sur le site du greffe : <a href="https://www.infogreffe.fr/documents-officiels/extrait-kbis">www.infogreffe.fr/documents-officiels/extrait-kbis</a>. Le coût de la formalité est défini par le greffe.</p>
          <p><strong>Attention : l'extrait Kbis ne concerne que les activités commerciales</strong>.</p>
          <p>De façon générale, il est souvent possible de fournir d'autres justificatifs d'existence comme :</p>
          <ul>
            <li>un extrait de votre inscription au Registre national des entreprises (extrait RNE)</li>
            <li>un avis de situation de l'Insee</li>
          </ul>
          <p>Ces deux documents sont à télécharger gratuitement sur <a href="https://annuaire-entreprises.data.gouv.fr">annuaire-entreprises.data.gouv.fr</a>.</p>
          <p>Enfin, si votre entreprise est « non diffusible », vous avez la possibilité de modifier ce statut pour télécharger vos documents : <a href="https://statut-diffusion-sirene.insee.fr">Accueil - Statut de diffusion Sirene - Insee</a></p>
        HTML
      },
      {
        email_type: 'mediateurs',
        body_html: <<~HTML.strip
          <p>Malheureusement, nous n'avons pas encore d'expert en mesure de répondre à votre problématique dans votre secteur d'activité.</p>
          <p>Nous vous conseillons de :</p>
          <ul>
            <li>procéder à un recouvrement amiable : par voie d'huissier, par exemple. La procédure est simplifiée jusqu'à 5 000 euros. Elle est enclenchée à l'initiative du créancier qui peut le faire directement via la plateforme de traitement des petites créances de la Chambre nationale des commissaires de justice : <a href="https://www.credicys.fr">https://www.credicys.fr</a></li>
            <li>se faire conseiller par un juriste via les informations suivantes : <a href="https://www.service-public.gouv.fr/particuliers/vosdroits/F20706">Comment consulter gratuitement un avocat ?</a></li>
          </ul>
          <p>Voici également la liste des différents médiateurs en fonction de votre besoin :</p>
          <ul>
            <li>Litige avec un gestionnaire des cotisations sociales : <ul><li>Médiateur de la MSA : <a href="https://www.msa.fr/lfp/le-mediateur-de-la-msa">https://www.msa.fr</a></li><li>Médiateur de l'URSSAF : <a href="https://www.urssaf.fr/portail/home/utile-et-pratique/mediation.html">https://www.urssaf.fr</a></li></ul></li>
            <li>Litige avec les impôts et services douaniers : <ul><li>Médiateur de Bercy : <a href="https://www.economie.gouv.fr/mediateur/mediateur-bercy">https://www.economie.gouv.fr</a></li></ul></li>
            <li>Litige avec France Travail : <ul><li>Médiateur France Travail : <a href="https://www.francetravail.fr/candidat/vos-droits-et-demarches/reclamations/le-mediateur-de-pole-emploi.html">https://www.francetravail.fr</a></li></ul></li>
            <li>Litige lié à la formation professionnelle : <ul><li>Médiateur de France Compétences : <a href="https://www.francecompetences.fr/espace-mediation-de-france-competences">https://www.francecompetences.fr</a></li></ul></li>
            <li>Litige lié à l'énergie : <ul><li>Médiateur National de l'énergie : <a href="https://www.energie-mediateur.fr">https://www.energie-mediateur.fr</a></li></ul></li>
            <li>Litige lié au domaine agricole : <ul><li>Médiateur des relations commerciales agricoles : <a href="https://agriculture.gouv.fr/le-mediateur-des-relations-commerciales-agricoles">https://agriculture.gouv.fr</a></li></ul></li>
            <li>Litige lié aux assurances : <ul><li>Médiateur des assurances : <a href="https://www.mediation-assurance.org">https://www.mediation-assurance.org</a></li></ul></li>
            <li>Litige avec la ville de Paris ou de la Région Île de France : <ul><li>Médiateur de la ville de Paris : <a href="https://www.paris.fr/pages/le-mediateur-de-paris-2687/">https://www.paris.fr</a></li><li>Médiateur de le région Île de France : <a href="https://www.iledefrance.fr/saisir-le-mediateur-de-la-region-ile-de-france">https://www.iledefrance.fr</a></li></ul></li>
          </ul>
        HTML
      },
      {
        email_type: 'moderation',
        body_html: <<~HTML.strip
          <p>Cette demande fait suite à une précédente demande, prise en charge par le ou les conseillers compétents sur votre territoire.</p>
          <p>Nous assurons le suivi qualité de cette demande initiale afin que vous soyez bien appelé(e) par un conseiller. Nous vous invitons à bien <b>vérifier votre messagerie</b> électronique, vos courriers indésirables (spams) et votre messagerie vocale.</p>
          <p>En l'absence d'élément nouveau, nous ne pouvons réaliser de nouvelles mises en relation vers ce dernier.</p>
        HTML
      },
      {
        email_type: 'no_expert',
        body_html: <<~HTML.strip
          <p>Malheureusement, nous n'avons pas encore d'expert en mesure de répondre à votre problématique dans votre secteur d'activité.</p>
          <p>C'est en détectant de nouvelles problématiques que nous pouvons améliorer ce service public.<strong> Nous faisons notre maximum pour compléter l'expertise</strong>.</p>
          <p>Liens utiles selon votre démarche :</p>
          <ul>
            <li>pour réaliser vos formalités d'entreprises : <a href="https://procedures.inpi.fr">https://procedures.inpi.fr</a>, ou pour les SCI <a href="https://tribunal-commerce.fr">https://tribunal-commerce.fr</a></li>
            <li>pour devenir un service à la personne : <a href="https://www.servicesalapersonne.gouv.fr">https://www.servicesalapersonne.gouv.fr</a></li>
            <li>pour votre établissement recevant du public (ERP) et son accessibilité : <a href="https://entreprendre.service-public.gouv.fr/vosdroits/F32351">https://entreprendre.service-public.gouv.fr</a></li>
            <li>pour votre problématique juridique, vous rapprocher d'un <a href="https://www.justice.gouv.fr/annuaire/lieux-daccueil-dinformation/point-justice">point d'accès justice</a> ou d'une <a href="https://www.service-public.gouv.fr/particuliers/vosdroits/F20706">permanence gratuite d'avocat</a></li>
          </ul>
        HTML
      },
      {
        email_type: 'no_expert_agri',
        body_html: <<~HTML.strip
          <p>Malheureusement, nous n'avons pas encore d'expert en mesure de répondre à votre problématique dans votre secteur d'activité.</p>
          <p>C'est en détectant de nouvelles problématiques que nous pouvons améliorer ce service public.<strong> Nous faisons notre maximum pour compléter l'expertise</strong>.</p>
          <p>Liens utiles selon votre démarche :</p>
          <ul>
            <li><b>pour les activités agricoles</b> : <a href="https://chambres-agriculture.fr/le-reseau-chambres/qui-sommes-nous/le-reseau-des-chambres-dagriculture">L'annuaire des Chambres d'agriculture - Chambres d'agriculture France (chambres-agriculture.fr)</a></li>
          </ul>
          <p>Vous retrouverez toutes les sources de financement possibles pour votre projet sur les sites suivants :</p>
          <ul>
            <li>Bpifrance : <a href="https://bpifrance-creation.fr/boiteaoutils/comment-financer-mon-projet-creation-ou-reprise-dentreprise">Comment financer mon projet de création ou reprise d'entreprise ? | Bpifrance Création (bpifrance-creation.fr)</a></li>
            <li>Banque de France : <a href="https://www.mesquestionsdentrepreneur.fr/creer-entreprise/financer-creation-entreprise">Mes questions d'entrepreneur | Financer ma création (mesquestionsdentrepreneur.fr)</a></li>
            <li>Réseau Initiative : <a href="https://initiative-france.fr">Accueil - Initiative - France</a></li>
            <li>Adie : <a href="https://www.adie.org">Avec l'Adie : entreprendre c'est possible !</a></li>
          </ul>
        HTML
      },
      {
        email_type: 'recruitment_foreign_worker',
        body_html: <<~HTML.strip
          <p>La demande d'autorisation de travail relève d'un service en ligne du Ministère de l'Intérieur : <a href="https://administration-etrangers-en-france.interieur.gouv.fr/immiprousager/#/authentification">https://administration-etrangers-en-france.interieur.gouv.fr</a>.</p>
          <p>Pour plus d'informations : <b>0806 001 620</b> (appel gratuit).</p>
        HTML
      },
      {
        email_type: 'retirement_liberal_professions',
        body_html: <<~HTML.strip
          <p>Malheureusement, les organismes compétents, la CIPAV (caisse de retraite des professions libérales), la CARPIMKO (caisse de retraite des auxiliaires médicaux) et la MSA (caisse de retraite des professions agricoles) ne sont pas encore partenaires du service.</p>
          <p>Nous vous invitons à les contacter en direct :</p>
          <ul>
            <li>la CIPAV au 01 44 95 68 20 du lundi au vendredi, de 8h30 à 18h00 ou sur le lien suivant : <a href="https://www.lacipav.fr/nous-contacter">https://www.lacipav.fr/nous-contacter</a></li>
            <li>la CARPIMKO au 01 30 48 10 00 : Du lundi au vendredi, de 8h45 à 12h45, la Carpimko répond à vos questions et vous guide dans vos démarches.</li>
          </ul>
        HTML
      },
      {
        email_type: 'sie_sip_declare_and_pay',
        body_html: <<~HTML.strip
          <p>Les questions relatives à la déclaration de vos revenus et à leur imposition relèvent de votre service des impôts des particuliers (SIP), tandis que les questions relatives à la CFE et à la TVA relèvent de votre service des impôts des entreprises (SIE).</p>
          <p><strong>Malheureusement ces deux services ne sont pas partenaires du Service Public Conseillers entreprises à ce jour</strong>.<br>Nous vous invitons à les solliciter directement :</p>
          <ul>
            <li>Service des impôts des particuliers (SIP) : <a href="https://lannuaire.service-public.gouv.fr/navigation/sip">https://lannuaire.service-public.gouv.fr/navigation/sip</a></li>
            <li>Service des impôts des entreprises (SIE) : <a href="https://lannuaire.service-public.gouv.fr/navigation/sie">https://lannuaire.service-public.gouv.fr/navigation/sie</a></li>
          </ul>
          <p>Vous pouvez également joindre ces services sur votre compte professionnel ou votre compte particulier <a href="https://cfspro-idp.impots.gouv.fr/oauth2/authorize?response_type=code&redirect_uri=https%3A%2F%2Fcfspro.impots.gouv.fr">impots.gouv.fr</a>, via votre messagerie personnalisée.</p>
        HTML
      },
      {
        email_type: 'sie_tva_and_others',
        body_html: <<~HTML.strip
          <p>Les démarches et les questions relatives à la TVA (déclaration et paiement de la TVA, obtention d'un n° de TVA intracommunautaire, seuil et changement de régime de TVA …) relèvent de votre service des impôts des entreprises (SIE).</p>
          <p><b>Malheureusement ce service n'est pas partenaire du Service Public Conseillers entreprises à ce jour</b>. Nous vous invitons à prendre directement contact avec votre SIE : <a href="https://lannuaire.service-public.gouv.fr/navigation/sie">https://lannuaire.service-public.gouv.fr/navigation/sie</a>.</p>
          <p>Vous pouvez également joindre votre SIE sur votre compte professionnel <a href="https://cfspro-idp.impots.gouv.fr/">impots.gouv.fr</a>, dans votre espace de messagerie personnalisée.</p>
        HTML
      },
      {
        email_type: 'siret',
        body_html: <<~HTML.strip
          <p>Il semble cependant qu'il y ait une erreur sur votre numéro de Siret. Pourriez-vous nous le faire parvenir à nouveau ?</p>
          <p>Le numéro de Siret comporte <b>14 chiffres</b>. Si vous ne le connaissez pas, vous le trouverez facilement ici : <a href="https://annuaire-entreprises.data.gouv.fr/?mtm_campaign=placedesentreprises">https://annuaire-entreprises.data.gouv.fr</a></p>
          <p>Par précaution, indiquez également <b>la commune</b> sur laquelle vous exercez votre activité.</p>
          <p>Dès réception de ces éléments, nous transmettons votre demande au(x) conseiller(s) compétent(s) pour vous aider sur votre territoire. Ce(s) conseiller(s) vous rappelleront directement.</p>
        HTML
      },
      {
        email_type: 'tns_training',
        body_html: <<~HTML.strip
          <p>Malheureusement nous n'avons pas encore d'expert en mesure de répondre à votre problématique.</p>
          <p>Selon votre statut social de Travailleur Non Salarié, 4 organismes sont compétents :</p>
          <ul>
            <li><strong>pour les commerçants</strong> : <a href="https://communication-agefice.fr">https://communication-agefice.fr</a></li>
            <li><strong>pour les artisans</strong> : <a href="https://www.fafcea.com/">https://www.fafcea.com</a></li>
            <li><strong>pour les professions libérales</strong> : <a href="https://www.fifpl.fr/">https://www.fifpl.fr</a></li>
            <li><strong>pour les professions agricoles</strong> : <a href="https://vivea.fr">https://vivea.fr</a></li>
          </ul>
        HTML
      }
    ]

    templates.each do |attrs|
      SolicitationMailTemplate.find_or_create_by!(email_type: attrs[:email_type]) do |email|
        email.body_html = attrs[:body_html]
      end
    end
  end

  def down
    SolicitationMailTemplate.destroy_all
  end
end
