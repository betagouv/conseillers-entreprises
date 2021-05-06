class FaqGenerator

  attr_reader :base_faq

  def initialize(values)
    @base_faq = values
  end

  # On n'affiche pas la 1ere question, déjà affiché avec les 3 icones sur la meme page
  def to_html
    @base_faq.drop(1)
  end

  def to_ld_json
    {
      "@context": "https://schema.org",
      "@type": "FAQPage",
      mainEntity: ld_json_faq_array
    }.to_json
  end

  private

  def ld_json_faq_array
    @base_faq.each_with_object([]) do |item, new_array|
      new_array << {
        "@type": "Question",
        name: item[:question],
        acceptedAnswer: {
          "@type": "Answer",
          text: item[:answer]
        }
      }
    end
  end

end