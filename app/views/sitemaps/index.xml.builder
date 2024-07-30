# frozen_string_literal: true
xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.sitemapindex xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.sitemap do
    xml.loc static_sitemap_url(format: :xml)
  end

  @cities.each do |city|
    xml.sitemap do
      xml.loc city_sitemap_index_url(city.slug, format: :xml)
    end
  end
end
