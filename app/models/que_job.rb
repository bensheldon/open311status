# == Schema Information
#
# Table name: que_jobs
#
#  args        :json             not null
#  error_count :integer          default(0), not null
#  job_class   :text             not null
#  last_error  :text
#  priority    :integer          default(100), not null, primary key
#  queue       :text             default(""), not null, primary key
#  run_at      :datetime         not null, primary key
#  job_id      :bigint(8)        not null, primary key
#

class QueJob < ApplicationRecord
  self.primary_keys = :queue, :priority, :run_at, :job_id
end
