require 'rails_helper'

RSpec.describe "Cities", :type => :request do
  describe "GET /cities" do
    it "works! (now write some real specs)" do
      get cities_path
      expect(response.status).to be(200)
    end
  end
end
