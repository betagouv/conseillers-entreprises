class AboutController < PagesController
  def cgu; end

  def politique_de_confidentialite; end

  def mentions_legales; end

  def comment_ca_marche
    @institutions = Rails.cache.fetch("institutions-#{Institution.maximum(:updated_at)}") do
      institutions = Institution.where(show_on_list: true).pluck(:name).sort
      institutions.each_slice((institutions.count.to_f / 4).ceil).to_a
    end
  end

  def top_5; end

  def satisfaction; end
end
