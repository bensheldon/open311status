# frozen_string_literal: true

# == Schema Information
#
# Table name: cities
#
#  id                        :bigint           not null, primary key
#  service_definitions_count :integer          default(0), not null
#  slug                      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_cities_on_slug  (slug) UNIQUE
#
FactoryBot.define do
  factory :city do
    slug { 'chicago' }

    initialize_with { City.instance(slug) }
  end
end
