# == Schema Information
#
# Table name: statuses
#
#  id            :bigint(8)        not null, primary key
#  city_id       :integer
#  request_name  :string
#  duration_ms   :integer
#  http_code     :integer
#  created_at    :datetime
#  error_message :text
#
# Indexes
#
#  index_statuses_on_city_id                   (city_id)
#  index_statuses_on_city_id_and_request_name  (city_id,request_name)
#

require 'rails_helper'

RSpec.describe Status, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
