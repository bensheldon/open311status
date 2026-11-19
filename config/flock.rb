# frozen_string_literal: true

# Runs a block while it holds a file lock, so that only one process does the work at a time.
module Flock
  DEFAULT_DIR = Rails.root.join('tmp').freeze
  SLEEP_INTERVAL = 0.01

  class LockTimeout < StandardError
  end

  # The lockfile stays after the block finishes.
  def self.with_lock(lockname, timeout: 10)
    FileUtils.mkdir_p(DEFAULT_DIR)

    File.open(DEFAULT_DIR.join("#{lockname}.lock"), File::CREAT) do |file|
      deadline = Time.current + timeout
      until file.flock(File::LOCK_EX | File::LOCK_NB)
        raise LockTimeout, "Could not obtain lock in #{timeout}s" if Time.current >= deadline

        sleep SLEEP_INTERVAL
      end

      yield
    end
  end
end
