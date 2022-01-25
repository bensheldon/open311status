# frozen_string_literal: true

require "rails_helper"

RSpec.describe CitiesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/cities").to route_to("cities#index")
    end

    it "routes to #show" do
      expect(get: "/cities/chicago").to route_to("cities#show", slug: "chicago")
    end

    describe 'requests' do
      it 'routes to cities/requests' do
        expect(get: "/cities/san_francisco/requests/12345/my-request").to route_to("cities/requests#show",
                                                                                   city_slug: "san_francisco",
                                                                                   service_request_id: "12345",
                                                                                   slug: "my-request")
      end
    end
  end
end
