class CitiesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "cities"
  end

  def unsubscribed
    stop_all_streams
  end
end