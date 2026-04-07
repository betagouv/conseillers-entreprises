module AboutSeoHelper
  # Helpers pour simplifier la configuration des schémas SEO dans les pages "About"
  
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
