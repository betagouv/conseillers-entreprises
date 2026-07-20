module AboutSeoHelper
  # Helpers pour simplifier la configuration des schémas SEO dans les pages "About"

  def setup_temoignages_index_seo(temoignages:)
    title = t('about.temoignages_experts.index.meta_title')
    description = t('about.temoignages_experts.index.meta_description')

    meta(title: title, description: description)
    add_page_schema(page_schema(
                      title: title,
                      description: description,
                      breadcrumb: true,
                      main_entity_id: "#{request.original_url}#itemlist"
                    ))
    add_page_schema(temoignages_list_schema(temoignages: temoignages))
  end

  def setup_temoignage_show_seo(temoignage:, key:)
    title = strip_tags(temoignage.title)
    description = strip_tags(temoignage.subtitle)
    image = image_url("temoignages_experts/#{key}.jpeg")

    set_og_image(image)
    meta(
      title: title,
      description: description,
      og: { type: 'article', title: title, description: description, image: { alt: temoignage.expert } },
      article: {
        published_time: temoignage.initial_publication_date.in_time_zone.iso8601,
        modified_time: temoignage.publication_date.in_time_zone.iso8601
      }
    )
    add_page_schema(page_schema(
                      title: title,
                      description: description,
                      breadcrumb: true,
                      main_entity_id: "#{request.original_url}#article"
                    ))
    add_page_schema(temoignage_article_schema(temoignage: temoignage, image: image))
  end

  def setup_comment_ca_marche_seo_schemas(temoignages:)
    title = t('about.comment_ca_marche.meta_title')
    description = t('about.comment_ca_marche.meta_description')

    meta(title: title, description: description)
    add_page_schema(page_schema(
                      title: title,
                      description: description,
                      breadcrumb: true,
                      main_entity_id: "#{request.original_url}#faqpage"
                    ))

    # Ajouter le schéma FAQ
    faq_items = I18n.t('faq').values
    add_page_schema(faq_page_schema(faq_items))

    # Ajouter les schémas de témoignages
    temoignages.each_with_index do |temoignage, index|
      if temoignage.published?
        add_page_schema(review_schema(
                          author: temoignage.author,
                          content: temoignage.content,
                          index: index + 1
                        ))
      end
    end
  end
end
