class FaqGenerator
  attr_reader :base_faq

  def initialize(values)
    @base_faq = values
  end

  # On n'affiche pas la 1ere question, déjà affiché avec les 3 icones sur la meme page
  def to_html
    @base_faq.drop(1)
  end
end
