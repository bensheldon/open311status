# frozen_string_literal: true

require 'open3'

# Builds a Pagefind (https://pagefind.app) search index of every service request
# into public/pagefind. It uses the pagefind npm package, so Node must be installed.
class Pagefind
  OUTPUT_PATH = Rails.public_path.join('pagefind').freeze
  HASH_FILE = Rails.root.join('tmp/pagefind.hash').freeze

  def self.build
    new.build
  end

  def build
    cache_key = data_cache_key
    if HASH_FILE.exist? && HASH_FILE.read == cache_key && OUTPUT_PATH.join('pagefind.js').exist?
      Rails.logger.debug 'Pagefind index up to date, skipping build'
      return
    end

    output, status = Open3.capture2e('node', '--input-type=module', stdin_data: script, chdir: Rails.root.to_s)
    Rails.logger.info output
    raise "Pagefind build failed:\n#{output}" unless status.success?

    FileUtils.mkdir_p(HASH_FILE.dirname)
    HASH_FILE.write(cache_key)
  end

  private

  def data_cache_key
    files = DataStore.path.glob('cities/*/*.yml').sort
    [DataStore.path.to_s, *files.map { |f| "#{f.relative_path_from(DataStore.path)}:#{f.mtime.to_f}" }].join("\n")
  end

  def records
    helpers = Rails.application.routes.url_helpers
    City.service_requests.map do |sr|
      raw = sr.raw_data
      title = [raw['service_name'].presence || 'Service request', sr.city.name].join(' in ')
      {
        url: helpers.service_request_path(sr),
        content: [raw['service_name'], raw['description'], raw['address'], sr.status, sr.city.name].compact_blank.join("\n"),
        meta: { title:, city: sr.city.name, requested: sr.requested_datetime&.strftime('%B %-d, %Y').to_s },
        filters: { city: [sr.city.name] },
      }
    end
  end

  def script
    <<~JS
      import * as pagefind from "pagefind";

      const records = #{records.to_json};
      const outputPath = #{OUTPUT_PATH.to_s.to_json};

      const { index } = await pagefind.createIndex({ forceLanguage: "en" });
      for (const record of records) {
        const { errors } = await index.addCustomRecord({ ...record, language: "en" });
        if (errors.length) console.error("Pagefind errors for", record.url, errors);
      }

      const { errors } = await index.writeFiles({ outputPath });
      await pagefind.close();
      if (errors.length) {
        console.error("Pagefind write errors:", errors);
        process.exit(1);
      }
      console.log(`Pagefind indexed ${records.length} records`);
    JS
  end
end
