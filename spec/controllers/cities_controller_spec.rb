require 'rails_helper'

RSpec.describe CitiesController, type: :controller do
  render_views

  describe "GET index" do
    let!(:city) { FactoryBot.create :city }

    it "assigns all cities as @cities" do
      get :index
      expect(assigns(:cities)).to eq([city])
    end
  end

  describe "GET show" do
    let!(:city) { FactoryBot.create :city }

    it "assigns the requested city as @city" do
      get :show, params: { slug: city.to_param }
      expect(assigns(:city)).to eq(city)
    end
  end
end
