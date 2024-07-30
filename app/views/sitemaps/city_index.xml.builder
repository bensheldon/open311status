# frozen_string_literal: true
xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.sitemapindex xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @dates.each do |date|
    xml.sitemap do
      xml.loc city_day_sitemap_url(@city.slug, date.strftime("%Y-%m-%d"), format: :xml)
      xml.lastmod date.strftime("%Y-%m-%dT%H:%M:%S%:z")
    end
  end
end
