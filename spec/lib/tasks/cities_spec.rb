require 'rails_helper'

RSpec.describe "cities:cleanup", type: :rake do
  include_context "rake"

  let(:city) { Cities::SanFrancisco.instance }

  it 'deletes old service requests and statuses' do
    service_requests = FactoryBot.create_list :service_request, 2, city: city, created_at: 3.days.ago
    statuses = FactoryBot.create_list :status, 2, city: city, created_at: 3.days.ago

    expect {
      task.invoke
    }.to change { ServiceRequest.count }.from(2).to(0)
        .and change { Status.count }.from(2).to(0)
  end
end