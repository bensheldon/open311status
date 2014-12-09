class Status < ActiveRecord::Base
  belongs_to :city

  validates :request_name, inclusion: { in: %w[service_list service_requests] }
end
