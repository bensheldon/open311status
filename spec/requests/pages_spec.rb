# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages' do
  before { write_city_data('chicago') }

  let(:service_request) { City.find('chicago').service_requests.first }

  it 'renders the home page' do
    get '/'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Chicago, IL', '50.0% uptime')
  end

  it 'renders the about page' do
    get '/about'
    expect(response).to have_http_status(:ok)
  end

  it 'renders a city page' do
    get '/cities/chicago'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(service_request.raw_data['service_name'])
  end

  it 'renders a city with no data' do
    get '/cities/baltimore'
    expect(response).to have_http_status(:ok)
  end

  it 'renders a service request page' do
    get Rails.application.routes.url_helpers.service_request_path(service_request)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(service_request.raw_data['service_name'])
  end

  it 'paginates all requests' do
    get '/requests'
    expect(response).to have_http_status(:ok)
    expect { get '/requests/page/99' }.to raise_error(ActionController::RoutingError)
  end

  it 'renders sitemaps' do
    get '/sitemap.xml'
    expect(response.body).to include('/sitemaps/chicago.xml')
    get '/sitemaps/chicago.xml'
    expect(response.body).to include('/cities/chicago/requests/')
  end

  it 'renders the static sitemap' do
    get '/sitemaps/static.xml'
    expect(response.body).to include('/about', '/requests', '/cities/chicago')
  end

  it 'links between request pages' do
    stub_const('RequestsController::PER_PAGE', 1)
    write_city_data('chicago', service_requests: Array.new(3) { |i| { 'service_request_id' => i.to_s } })
    get '/requests'
    expect(response.body).to include('/requests/page/2')
    expect(response.body).not_to include('Newer requests')

    get '/requests/page/2'
    expect(response.body).to include('href="/requests"', '/requests/page/3')
  end

  it 'renders a request without a description at its id path' do
    write_city_data('chicago', service_requests: [{ 'service_request_id' => 'abc.1', 'service_name' => 'Graffiti' }])
    get '/cities/chicago/requests/abc.1'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Graffiti')
  end

  it 'raises a routing error for an unknown city' do
    expect { get '/cities/nowhere' }.to raise_error(ActionController::RoutingError)
  end
end
