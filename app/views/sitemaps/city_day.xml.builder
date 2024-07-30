# frozen_string_literal: true
xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @service_requests.each do |service_request|
    xml.url do
      xml.loc service_request_url(service_request, format: :xml)
      xml.lastmod format_lastmod(service_request.updated_at)
    end
  end
end
