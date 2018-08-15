Rails.application.routes.draw do
  root 'cities#index'
  resources :cities, only: [:index, :show], param: :slug do
    scope module: :cities do
      resources :requests, only: [:show], param: :service_request_id do
        member do
          get ':slug', to: 'requests#show', as: :slug
        end
      end
    end
  end

  get '/sitemap.xml.gz', to: redirect("https://#{Rails.application.secrets.s3_bucket_name}.s3.amazonaws.com/sitemaps/sitemap.xml.gz")

  resolve "ServiceRequest" do |service_request, options|
    slug_city_request_url(service_request.city.slug, service_request.service_request_id, service_request.slug, options)
  end
end
