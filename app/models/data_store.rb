# frozen_string_literal: true

# Reads and writes per-city YAML files in the data directory, which is a
# checkout of the `data` branch (see bin/data).
#
#   data/cities/<slug>.yml
#     service_definitions: [ <raw Open311 service hashes> ]
#     statuses: [ { request_name:, created_at:, http_code:, duration_ms:, error_message: } ]
#     service_requests: [ <raw Open311 request hashes> ]
class DataStore
  KEYS = %w[service_definitions statuses service_requests].freeze

  def self.path
    Rails.configuration.data_path
  end

  def self.city_path(slug)
    path.join('cities', "#{slug}.yml")
  end

  def self.read(slug)
    file = city_path(slug)
    data = file.exist? ? YAML.safe_load_file(file) || {} : {}
    KEYS.index_with { |key| Array(data[key]) }
  end

  def self.write(slug, data)
    file = city_path(slug)
    FileUtils.mkdir_p(file.dirname)
    File.write(file, data.slice(*KEYS).to_yaml(line_width: -1))
  end

  # Cache key that changes whenever any data file changes.
  def self.fingerprint
    Dir.glob(path.join('cities', '*.yml')).map { |f| [f, File.mtime(f).to_f] }.hash
  end
end
