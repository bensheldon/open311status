# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'General' do
  it 'can visit static pages' do
    visit root_path
    click_on 'About'
    expect(page).to have_text 'About Open311 Status'
  end
end
