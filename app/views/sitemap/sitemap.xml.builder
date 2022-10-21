# Human-readable spec: https://www.sitemaps.org/fr/protocol.html
def site_map_xml(element, xml)
  xml_return = ""
  element.each do |el|
    e = el.last
    if e[:href] == true
      xml_return << xml.tag!("url") do
        xml.loc e[:loc]
        xml.lastmod e[:lastmod]
        xml.priority e[:priority]
        xml.changefreq 'weekly'
      end
    end
    if e[:elements]
      e[:elements].each do |elem|
        xml_return << site_map_xml(elem, xml)
      end
    end
  end
  xml_return
end

xml.instruct!
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @site_map.each do |element|
    site_map_xml(element, xml)
  end
end
