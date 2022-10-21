class SitemapController < PagesController
  respond_to :html, :xml

  def sitemap
    @site_map = SitemapGenerator.perform
    respond_with(@site_map) do |format|
      format.html do
        # @breadcrumbs = []
        # @breadcrumbs << [ "Accueil", root_path ]
        # @breadcrumbs << [ "Plan du site", sitemap_path ]
      end
      format.xml { render layout: false }
    end
  end
end
