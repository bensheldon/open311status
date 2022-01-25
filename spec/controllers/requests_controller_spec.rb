# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RequestsController, type: :controller do
  render_views

  describe "GET index" do
    let!(:city) { City.instance(:chicago) }
    let!(:service_requests) { create_list :service_request, 5 }

    it "assigns a pager" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(assigns(:pager)).to be_a ServiceRequestsPager
    end
  end
end
