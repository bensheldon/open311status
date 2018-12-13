class RequestsController < ApplicationController
  include Pagy::Backend

  def index
    @pager = ServiceRequestsPager.new(
      before_id: params[:before_id],
      after_id: params[:after_id]
    )
  end
end
