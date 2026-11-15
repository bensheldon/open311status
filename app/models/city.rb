# frozen_string_literal: true

class City
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  # How long data is kept in the data branch's JSON Lines files (older data remains in git history).
  STATUS_RETENTION = 6.months
  SERVICE_REQUEST_RETENTION = 7.days
  WINDOW = 48.hours

  delegate(*Configuration::ATTRIBUTES, to: :configuration)

  attr_reader :slug, :service_definitions, :statuses, :service_requests

  class << self
    def all
      fingerprint = DataStore.fingerprint
      @_all = nil if @_fingerprint != fingerprint
      @_fingerprint = fingerprint
      @_all ||= Rails.configuration.cities.keys.sort.map { |slug| new(slug) }
    end

    def find(slug)
      all.find { |city| city.slug == slug } || raise(ActionController::RoutingError, "City not found: #{slug}")
    end

    def service_requests
      all.flat_map(&:service_requests).sort_by { |sr| sr.requested_datetime || Time.zone.at(0) }.reverse
    end
  end

  def initialize(slug)
    @slug = slug
    data = DataStore.read(slug)
    @service_definitions = data['service_definitions'].map { |raw| ServiceDefinition.new(raw) }
    @statuses = data['statuses'].map { |attrs| Status.new(**attrs.symbolize_keys) }
    load_service_requests(data['service_requests'])
  end

  def to_param
    slug
  end

  def persisted?
    true
  end

  def id
    slug
  end

  def configuration
    @_configuration ||= City::Configuration.new(Rails.configuration.cities.fetch(slug))
  end

  def api
    @_api ||= City::Api.new(self)
  end

  def save
    prune
    DataStore.write(slug, {
                      'service_definitions' => service_definitions.map(&:raw_data),
      'statuses' => statuses.sort_by(&:created_at).map(&:to_h),
      'service_requests' => service_requests.sort_by { |sr| sr.service_request_id.to_s }.map(&:raw_data),
                    })
  end

  def service_definitions=(raw_list)
    @service_definitions = raw_list.map { |raw| ServiceDefinition.new(raw) }
  end

  def add_status(status)
    @statuses << status
  end

  def merge_service_requests(raw_list)
    by_id = service_requests.index_by(&:service_request_id)
    raw_list.each do |raw|
      sr = ServiceRequest.new(self, raw)
      by_id[sr.service_request_id] = sr if sr.service_request_id.present?
    end
    @service_requests = sort_requests(by_id.values)
  end

  def find_service_request(service_request_id)
    service_requests.find { |sr| sr.service_request_id == service_request_id } ||
      raise(ActionController::RoutingError, "Service request not found: #{service_request_id}")
  end

  def latest_requested_datetime
    service_requests.filter_map(&:requested_datetime).max
  end

  def service_definitions_count
    service_definitions.size
  end

  def service_list_status
    statuses_for('service_list').last
  end

  def service_requests_status
    statuses_for('service_requests').last
  end

  def statuses_for(request_name, since: nil)
    list = statuses.select { |s| s.request_name == request_name }.sort_by(&:created_at)
    since ? list.select { |s| s.created_at >= since } : list
  end

  # Percentage of checks in the window that succeeded.
  def uptime_percent(request_name, since: WINDOW.ago)
    checks = statuses_for(request_name, since:)
    return 0.0 if checks.empty?

    checks.count(&:success?) * 100.0 / checks.size
  end

  # { "2026-01-01T10:00:00Z" => count } for each hour in the window.
  def bucketed_service_requests
    @_bucketed_service_requests ||= begin
      now = Time.current.utc.beginning_of_hour
      hours = (0...WINDOW.in_hours.to_i).map { |i| now - i.hours }.reverse
      counts = service_requests.filter_map { |sr| sr.requested_datetime&.utc&.beginning_of_hour }.tally
      hours.to_h { |hour| [hour.iso8601, counts.fetch(hour, 0)] }
    end
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
    (total_service_requests.to_f / bucketed_service_requests.size).round(1)
  end

  private

  def load_service_requests(raw_list)
    @service_requests = sort_requests(raw_list.map { |raw| ServiceRequest.new(self, raw) })
  end

  def sort_requests(list)
    list.sort_by { |sr| sr.requested_datetime || Time.zone.at(0) }.reverse
  end

  def prune
    status_cutoff = STATUS_RETENTION.ago
    @statuses = statuses.select { |s| s.created_at >= status_cutoff }
    request_cutoff = SERVICE_REQUEST_RETENTION.ago
    @service_requests = service_requests.select { |sr| sr.requested_datetime.nil? || sr.requested_datetime >= request_cutoff }
  end
end
