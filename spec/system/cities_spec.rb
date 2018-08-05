require 'rails_helper'

RSpec.describe 'Cities', type: :system do
  before do
    City.load!
  end

  it 'shows all cities on frontpage' do
    visit root_path
    
    City.all.each do |city|
      expect(page).to have_text city.name
    end
  end
end
