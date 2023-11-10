module SitemapHelper
  def site_map_html(elements, pos = nil)
    html = ""

    elements.each do |elt|
      e = elt.last

      html_elt = case e[:level]
      when 1
        "h2 class='fr-h3'"
      when 2
        "h3 class='fr-h4'"
      when 3
        'li'
      else
        'p'
      end

      html << "<ul class='fr-mb-3w'>" if is_first_list_element(e, pos)

      html << "<#{html_elt}>"
      html << if e[:href] == true
        link_to(e[:title], e[:loc])
      else
        e[:title]
      end
      html << "</#{html_elt}>"

      if e[:elements].present?
        e[:elements].each_with_index do |elem, idx|
          pos = calculate_pos(elem, e[:elements])
          html << site_map_html(elem, pos)
        end
      end
      html << "</ul>" if is_last_list_element(e, pos)
    end

    html << ""
  end

  def is_first_list_element(e, pos = nil)
    e[:level] == 3 && pos == :first
  end

  def is_last_list_element(e, pos = nil)
    e[:level] == 3 && pos == :last
  end

  def calculate_pos(e, elements)
    return :first if e == elements.first
    return :last if e == elements.last
  end
end
