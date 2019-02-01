# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  describe '#about' do
    specify do
      get :about
      expect(response).to have_http_status :ok
    end
  end
end
