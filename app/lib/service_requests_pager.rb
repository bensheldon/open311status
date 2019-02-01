# frozen_string_literal: true

class ServiceRequestsPager
  LIMIT = 10

  def initialize(before_id: nil, after_id: nil)
    @before_id = before_id
    @after_id = after_id
  end

  def records
    @_records ||= if index_record && @before_id
                    ServiceRequest.includes(:city).order_requested_at(index_record).after.limit(LIMIT)
                  elsif index_record && @after_id
                    ServiceRequest.includes(:city).order_requested_at(index_record).before.limit(LIMIT).reverse
                  else
                    ServiceRequest.includes(:city).order_requested.limit(LIMIT)
                  end
  end

  def newer?
    if index_record && @before_id
      true
    elsif index_record && @after_id
      index_position - LIMIT > 1
    else
      false
    end
  end

  def older?
    if index_record && @after_id
      true
    else
      index_position + LIMIT < count
    end
  end

  private

  def index_record
    id = @after_id || @before_id
    return if id.blank?

    @_index_record ||= ServiceRequest.find(id)
  end

  def index_point
    return if index_record.blank?

    @_index_point ||= ServiceRequest.order_requested_at(index_record)
  end

  def index_position
    @_index_position ||= index_point&.position || 1
  end

  def count
    @_count ||= ServiceRequest.count
  end
end
