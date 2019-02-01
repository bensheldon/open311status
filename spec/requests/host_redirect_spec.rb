# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Host Redirection' do
  it 'redirects from heroku' do
    host! 'open311status.herokuapp.com'
    expect(get(root_path)).to redirect_to root_url(host: 'status.open311.org')
  end
end
