# frozen_string_literal: true

class StatusDecorator < Draper::Decorator
  delegate_all

  def quality
    if http_code != 200
      :error
    elsif duration_ms > 999
      :slow
    else
      :success
    end
  end

  def title
    {
      success: 'Okay',
      slow: 'Slow',
      error: 'Error',
    }[quality]
  end

  def description
    {
      success: "Server responded in #{duration_ms} ms",
      slow: "Server slow response of #{duration_ms} ms",
      error: error_description,
    }[quality]
  end

  def label_class
    {
      success: 'success',
      slow: 'warning',
      error: 'danger',
    }[quality]
  end

  private

  def error_description
    if status.http_code.present?
      "Server responded with #{http_code} after #{duration_ms} ms"
    else
      "Error processing response after #{duration_ms} ms: '#{error_message}'"
    end
  end
end
