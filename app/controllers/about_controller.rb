class AboutController < PagesController
  include IframePrefix

  def cgu; end

  def mentions_d_information; end

  def mentions_legales; end

  def accessibilite; end

  def comment_ca_marche
    @institutions = Rails.cache.fetch("institutions-#{Institution.maximum(:updated_at)}") do
      institutions = Institution.not_deleted.where(show_on_list: true).pluck(:name).sort
      institutions.each_slice((institutions.count.to_f / 4).ceil).to_a
    end
    @ld_json = FaqGenerator.new(I18n.t('faq').values).to_ld_json
    @faq = FaqGenerator.new(I18n.t('faq').values).to_html
  end

  def equipe; end

  def service_public_fr; end
end
