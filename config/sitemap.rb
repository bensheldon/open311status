default_url_options = Rails.application.config.action_mailer.default_url_options

SitemapGenerator::Sitemap.default_host = root_url(default_url_options).chomp '/'
SitemapGenerator::Sitemap.sitemaps_host = Rails.application.secrets.upload_host
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.public_path = 'tmp/'

if Rails.env.production?
  require 'aws-sdk-s3'

  SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new(
      Rails.application.secrets.s3_bucket_name,
      aws_access_key_id: Rails.application.secrets.s3_access_key_id,
      aws_secret_access_key: Rails.application.secrets.s3_secret_access_key,
      aws_region: 'us-east-1'
  )
else
  SitemapGenerator::Sitemap.adapter = SitemapGenerator::FileAdapter.new
end

SitemapGenerator::Sitemap.create do
  City.find_each do |city|
    add city_path(city, default_url_options), changefreq: 'daily'
  end

  ServiceRequest.includes(:city).find_each do |service_request|
    add service_request_path(service_request, default_url_options), lastmod: service_request.updated_at, changefreq: 'weekly'
  end
end
