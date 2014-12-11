class CityDecorator < Draper::Decorator
  delegate_all

  decorates_association :service_list_status
  decorates_association :service_requests_status
end
