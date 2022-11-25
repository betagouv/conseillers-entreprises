module SitemapHelper
  def site_map_html(elements)
    html = "<ul>"

    elements.each do |elt|
      e = elt.last

      html << "<li>"
      html << if e[:href] == true
        link_to(e[:title], e[:loc])
      else
        e[:title]
      end
      html << "</li>"

      if e[:elements].present?
        e[:elements].each do |elem|
          html << site_map_html(elem)
        end
      end
    end

    html << "</ul>"
  end
end
