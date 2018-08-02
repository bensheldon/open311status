require "rails_helper"

RSpec.describe CitiesController, :type => :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/cities").to route_to("cities#index")
    end

    it "routes to #show" do
      expect(get: "/cities/chicago").to route_to("cities#show", slug: "chicago")
    end
  end
end
