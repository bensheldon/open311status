require 'rails_helper'

RSpec.describe 'Cities', type: :system do
  before do
    City.load!

    City.all.each do |city|
      FactoryBot.create :status, request_name: 'service_list', city: city, http_code: 500, created_at: 10.minutes.ago
      FactoryBot.create :status, request_name: 'service_requests', city: city, http_code: 500, created_at: 10.minutes.ago
    end
  end

  it 'shows all cities on frontpage' do
    visit root_path
    
    City.all.each do |city|
      expect(page).to have_text city.name
    end
  end
end
