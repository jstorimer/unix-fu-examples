require 'socket'
require 'rack'
require 'rack/builder'
require 'http_tools'

class MiniUnicorn
  NUM_WORKER = 5
  WORKER_PIDS = []
  SIGNAL_QUEUE = []
  SIGNAL_WE_CARE_ABOUT = [:INT, :QUIT, :USR2]
  SELF_PIPE_READER, SELF_PIPE_WRITER = IO.pipe

  def initialize(port = 8080)
    @listener = TCPServer.new(port)
  end

  def start
    load_app
    set_program_name
    spawn_workers
    trap_signals

    loop do
      IO.select([SELF_PIPE_READER])
      SELF_PIPE_READER.read(1) # clean out the pipe

      case SIGNAL_QUEUE.shift
      when :INT
        WORKER_PIDS.each do |wpid|
          Process.kill(:INT, wpid)
        end

        sleep 1
        WORKER_PIDS.each do |wpid|
          unless Process.waitpid(wpid, Process::WNOHANG)
            Process.kill(:KILL, wpid)
          end
        end

        exit

      when :USR2
        reexec
      end
    end
  end

  def load_app
    rackup_file = ENV.fetch('RU') { './config.ru' }
    @app, _ = Rack::Builder.parse_file(rackup_file)
  end

  def reexec
    puts "Going for hot restart..."

    fork {
      $PROGRAM_NAME = "MiniUnicorn (New Parent)"
      exec "ruby", "mini-unicorn.rb"
    }
  end

  def set_program_name
    $PROGRAM_NAME = 'MiniUnicorn (Parent)'
  end

  def spawn_workers
    NUM_WORKER.times do |num|
      spawn_worker(num)
    end
  end

  def trap_signals
    SIGNAL_WE_CARE_ABOUT.each do |sig|
      Signal.trap(sig) do
        SIGNAL_QUEUE << sig
        SELF_PIPE_WRITER.write('.')
      end
    end
  end

  def spawn_worker(num)
    WORKER_PIDS << Process.fork {
      $PROGRAM_NAME = "MiniUnicorn (Worker ##{num})"

      # after_fork
      #   ActiveRecord::Base.establish_connecetion
      #   Redis::Client.reconnect

      Signal.trap(:INT) {
        # gracefully finish the current request and then exit
        exit
      }

      worker_loop
    }
  end

  def worker_loop
    loop do
      connection, _ = @listener.accept
      
      raw_request = connection.readpartial(4096)

      parser = HTTPTools::Parser.new

      parser.on(:finish) do
        env = parser.env.merge!("rack.multiprocess" => true)
        status, header, body = @app.call(env)

        header["Connection"] = "close"
        connection.write HTTPTools::Builder.response(status, header)

        body.each {|chunk| connection.write chunk}
        body.close if body.respond_to?(:close)
      end

      parser << raw_request
      connection.close
    end
  end
end

server = MiniUnicorn.new
server.start

