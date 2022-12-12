# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Cities" do
  describe "GET /cities" do
    it "works! (now write some real specs)" do
      get cities_path
      expect(response).to have_http_status(:ok)
    end
  end
end
