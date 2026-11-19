Rails.application.routes.draw do
  root 'cities#index'
  get 'about', to: 'pages#about'

  resources :cities, only: [:index, :show], param: :slug do
    scope module: :cities do
      resources :requests, only: [:show], param: :service_request_id, constraints: { service_request_id: %r{[^/]+} } do
        member do
          get ':slug', to: 'requests#show', as: :slug
        end
      end
    end
  end

  get 'requests', to: 'requests#index', as: :requests
  get 'requests/page/:page', to: 'requests#index', as: :requests_page, constraints: { page: /\d+/ }

  get '/sitemap.xml', to: 'sitemaps#index', defaults: { format: 'xml' }, as: :sitemap
  get '/sitemaps/static.xml', to: 'sitemaps#static', defaults: { format: 'xml' }, as: :static_sitemap
  get '/sitemaps/:slug.xml', to: 'sitemaps#city', defaults: { format: 'xml' }, as: :city_sitemap

  direct :github do
    'https://github.com/codeforamerica/open311status'
  end

end

Rails.application.routes.named_routes.url_helpers_module.module_eval do
  def service_request_path(service_request, options = {})
    if service_request.slug.present?
      slug_city_request_path(service_request.city.slug, service_request.service_request_id, service_request.slug, options)
    else
      city_request_path(service_request.city.slug, service_request.service_request_id, options)
    end
  end

  def service_request_url(service_request, options = {})
    if service_request.slug.present?
      slug_city_request_url(service_request.city.slug, service_request.service_request_id, service_request.slug, options)
    else
      city_request_url(service_request.city.slug, service_request.service_request_id, options)
    end
  end
end
