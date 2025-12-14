# frozen_string_literal: true

# == Schema Information
#
# Table name: statuses
#
#  id            :bigint           not null, primary key
#  duration_ms   :integer
#  error_message :text
#  http_code     :integer
#  request_name  :string
#  created_at    :datetime
#  city_id       :bigint
#
# Indexes
#
#  index_statuses_on_city_id_and_request_name_and_created_at  (city_id,request_name,created_at DESC)
#  index_statuses_on_created_at                               (created_at)
#
# Foreign Keys
#
#  fk_rails_...  (city_id => cities.id) ON DELETE => cascade
#
require 'rails_helper'

RSpec.describe Status do
  pending "add some examples to (or delete) #{__FILE__}"
end
