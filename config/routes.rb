Rails.application.routes.draw do
  root 'cities#index'
  get 'about', to: 'pages#about'

  resources :cities, only: [:index, :show], param: :slug do
    scope module: :cities do
      resources :requests, only: [:show], param: :service_request_id do
        member do
          get ':slug', to: 'requests#show', as: :slug
        end
      end
    end
  end

  resources :requests, only: [:index]

  mount GoodJob::Engine => 'good_job'

  get '/sitemap.xml', to: 'sitemaps#index', defaults: { format: 'xml' }, as: :sitemap
  get '/sitemaps/static.xml', to: 'sitemaps#static', defaults: { format: 'xml' }, as: :static_sitemap
  get '/sitemaps/:slug.xml', to: 'sitemaps#city_index', defaults: { format: 'xml' }, as: :city_sitemap_index
  get '/sitemaps/:slug/:date.xml', to: 'sitemaps#city_day', defaults: { format: 'xml' }, as: :city_day_sitemap

  resolve "ServiceRequest" do |service_request, options|
    service_request.parameterize.merge(controller: 'cities/requests', action: 'show').merge(options)
  end

  direct :github do
    'https://github.com/codeforamerica/open311status'
  end
end

Rails.application.routes.named_routes.url_helpers_module.module_eval do
  def service_request_path(service_request, options = {})
    slug_city_request_path(service_request.city.slug, service_request.service_request_id, service_request.slug, options)
  end

  def service_request_url(service_request, options = {})
    slug_city_request_url(service_request.city.slug, service_request.service_request_id, service_request.slug, options)
  end
end
