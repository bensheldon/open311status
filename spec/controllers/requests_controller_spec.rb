require 'rails_helper'

RSpec.describe RequestsController, type: :controller do
  render_views

  describe "GET index" do
    let!(:city) { City.instance(:chicago) }
    let!(:service_requests) { FactoryBot.create_list :service_request, 5 }

    it "assigns all service requests" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(assigns(:service_requests)).to be_present
    end
  end
end