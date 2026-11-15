# frozen_string_literal: true

# Reads and writes each city's data as YAML files in the data
# directory, which is a checkout of the `data` branch (see bin/data).
#
#   data/cities/<slug>/service_definitions.yml
#   data/cities/<slug>/statuses.yml
#   data/cities/<slug>/requests.yml
class DataStore
  FILES = {
    'service_definitions' => 'service_definitions.yml',
    'statuses' => 'statuses.yml',
    'service_requests' => 'requests.yml',
  }.freeze

  def self.path
    Rails.configuration.data_path
  end

  def self.city_dir(slug)
    path.join('cities', slug)
  end

  # Returns { 'service_definitions' => [...], 'statuses' => [...], 'service_requests' => [...] }
  def self.read(slug)
    FILES.to_h { |key, name| [key, read_yaml(city_dir(slug).join(name))] }
  end

  def self.write(slug, data)
    FILES.each { |key, name| write_yaml(city_dir(slug).join(name), data.fetch(key, [])) }
  end

  # Cache key that changes whenever any data file changes.
  def self.fingerprint
    Dir.glob(path.join('cities', '*', '*.yml')).map { |f| [f, File.mtime(f).to_f] }.hash
  end

  def self.read_yaml(file)
    return [] unless file.exist?

    Array(YAML.safe_load_file(file))
  end

  def self.write_yaml(file, records)
    content = records.to_yaml(line_width: -1)
    return if file.exist? && file.read == content # avoid touching unchanged files

    FileUtils.mkdir_p(file.dirname)
    File.write(file, content)
  end

  private_class_method :read_yaml, :write_yaml
end
