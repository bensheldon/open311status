class ServiceRequestsPager
  def initialize(before_id: nil, after_id: nil)
    @before_id = before_id
    @after_id = after_id
  end

  private

  def index_record
    id = @after_id || @before_id
    @_index_record ||= ServiceRequest.find(id)
  end

  def index_point
    @_order_point ||= ServiceRequest.order_datetime_at(index_record)
  end
end
