# frozen_string_literal: true

# Reads and writes each city's data as JSON Lines files in the data directory,
# which is a checkout of the `data` branch (see bin/data). Files are split by
# date so that each hourly commit changes only a few small files.
#
#   data/cities/<slug>/service_definitions.jsonl
#   data/cities/<slug>/statuses/<YYYY-MM>.jsonl      (by created_at month, UTC)
#   data/cities/<slug>/requests/<YYYY-MM-DD>.jsonl   (by requested_datetime day, UTC)
class DataStore
  def self.path
    Rails.configuration.data_path
  end

  def self.city_dir(slug)
    path.join('cities', slug)
  end

  # Returns { 'service_definitions' => [...], 'statuses' => [...], 'service_requests' => [...] }
  def self.read(slug)
    dir = city_dir(slug)
    {
      'service_definitions' => read_jsonl(dir.join('service_definitions.jsonl')),
      'statuses' => dir.glob('statuses/*.jsonl').sort.flat_map { |file| read_jsonl(file) },
      'service_requests' => dir.glob('requests/*.jsonl').sort.flat_map { |file| read_jsonl(file) },
    }
  end

  # Statuses and service requests must have parseable `created_at` and
  # `requested_datetime` values; partition files no longer present are deleted.
  def self.write(slug, data)
    dir = city_dir(slug)
    write_jsonl(dir.join('service_definitions.jsonl'), data.fetch('service_definitions', []))

    statuses = data.fetch('statuses', []).group_by { |s| Time.zone.parse(s['created_at']).utc.strftime('%Y-%m') }
    write_partitions(dir.join('statuses'), statuses.transform_values { |list| list.sort_by { |s| s['created_at'] } })

    requests = data.fetch('service_requests', []).group_by { |r| Time.zone.parse(r['requested_datetime'].to_s).utc.strftime('%Y-%m-%d') }
    write_partitions(dir.join('requests'), requests.transform_values { |list| list.sort_by { |r| r['service_request_id'].to_s } })
  end

  # Cache key that changes whenever any data file changes.
  def self.fingerprint
    Dir.glob(path.join('cities', '**', '*.jsonl')).map { |f| [f, File.mtime(f).to_f] }.hash
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

  def self.write_partitions(dir, partitions)
    keep = partitions.keys.map { |key| dir.join("#{key}.jsonl") }
    dir.glob('*.jsonl').each { |file| file.delete unless keep.include?(file) }
    partitions.each { |key, records| write_jsonl(dir.join("#{key}.jsonl"), records) }
  end

  private_class_method :read_jsonl, :write_jsonl, :write_partitions
end
