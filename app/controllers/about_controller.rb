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
    @faq = I18n.t('faq').values
    # Rich snippets
    faq_to_ld_json = @faq.each_with_object([]) do |item, new_array|
      new_array << {
        "@type": "Question",
        name: item[:question],
        acceptedAnswer: {
          "@type": "Answer",
          text: item[:answer]
        }
      }
    end
    @ld_json = {
      "@context": "https://schema.org",
      "@type": "FAQPage",
      mainEntity: faq_to_ld_json
    }.to_json
  end
end
