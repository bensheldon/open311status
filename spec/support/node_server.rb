require 'open-uri'
require 'json'

class NodeServer
  attr_reader :pid, :port, :stdout

  def self.start
    new.tap do |server|
      server.start
    end
  end

  def start(options = {})
    @port = options.fetch :port, RSpec.configuration.node_server_port 
    @io_read, io_write = IO.pipe
    @pid = spawn({ 'NODE_PORT' => "#{ @port }" }, 'coffee push-server.coffee', out: io_write, err: io_write)
    @stdout = ''
    wait_for_stdout(/server listening/i) { stop }
  end

  def stop
    Process.kill('SIGINT', pid)
  end

  def wait_for_stdout(needle, options = {})
    timout = options.fetch(:timeout, 2)
    begin
      # The io_read pipe can only be read once
      # so keep appending output to stdout buffer
      # until we find the needle or timeout
      Timeout.timeout(timout) do
        found = false
        until found do
          begin
            stdout << @io_read.readline
            found = stdout.match needle
          rescue Errno::EIO
          end
          sleep(0.1)
        end
        @stdout
      end
    rescue Timeout::Error
      if block_given?
        yield
      else
        raise $!, "Searching for #{ match } in stdout:\n  #{ @stdout.gsub("\n", "\n  ") }", $!.backtrace
      end
    end
  end
end
