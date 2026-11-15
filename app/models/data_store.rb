# frozen_string_literal: true

# Reads and writes each city's data as JSON Lines files (one record per line)
# in the data directory, which is a checkout of the `data` branch (see bin/data).
#
#   data/cities/<slug>/service_definitions.jsonl
#   data/cities/<slug>/statuses.jsonl
#   data/cities/<slug>/requests.jsonl
class DataStore
  FILES = {
    'service_definitions' => 'service_definitions.jsonl',
    'statuses' => 'statuses.jsonl',
    'service_requests' => 'requests.jsonl',
  }.freeze

  def self.path
    Rails.configuration.data_path
  end

  def self.city_dir(slug)
    path.join('cities', slug)
  end

  # Returns { 'service_definitions' => [...], 'statuses' => [...], 'service_requests' => [...] }
  def self.read(slug)
    FILES.to_h { |key, name| [key, read_jsonl(city_dir(slug).join(name))] }
  end

  def self.write(slug, data)
    FILES.each { |key, name| write_jsonl(city_dir(slug).join(name), data.fetch(key, [])) }
  end

  # Cache key that changes whenever any data file changes.
  def self.fingerprint
    Dir.glob(path.join('cities', '*', '*.jsonl')).map { |f| [f, File.mtime(f).to_f] }.hash
  end

  def self.read_jsonl(file)
    return [] unless file.exist?

    file.each_line.filter_map { |line| JSON.parse(line) if line.present? }
  end

  def self.write_jsonl(file, records)
    content = records.map { |record| "#{JSON.generate(record)}\n" }.join
    return if file.exist? && file.read == content # avoid touching unchanged files

    FileUtils.mkdir_p(file.dirname)
    File.write(file, content)
  end

  private_class_method :read_jsonl, :write_jsonl
end
