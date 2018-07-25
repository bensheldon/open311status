class CityDecorator < Draper::Decorator
  delegate_all

  decorates_association :service_list_status
  decorates_association :service_requests_status

  def bucketed_service_requests
    @bucketed_service_requests ||= service_requests.group_by_hour(:requested_datetime, range: 2.days.ago..Time.current).count
  end

  def total_service_requests
    bucketed_service_requests.values.sum
  end

  def min_service_requests
    bucketed_service_requests.values.min || 0
  end

  def max_service_requests
    bucketed_service_requests.values.max || 0
  end

  def avg_service_requests
    (bucketed_service_requests.values.sum.to_f / 48).round(1)
  end
end
