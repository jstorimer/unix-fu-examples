require 'socket'
require 'rack'
require 'rack/builder'
require 'http_tools'

class MiniUnicorn
  NUM_WORKERS = 4
  CHILD_PIDS = []
  SIGNAL_QUEUE = []
  SELF_PIPE_R, SELF_PIPE_W = IO.pipe

  def initialize(port = 8080)
    if listener_fd = ENV['LISTENER_FD']
      @listener = TCPServer.for_fd(listener_fd.to_i)
    else
      @listener = TCPServer.new(port)
      @listener.listen(512)
    end
  end

  def start
    load_app
    spawn_workers
    trap_signals
    set_title

    loop do
      ready = IO.select([SELF_PIPE_R])
      SELF_PIPE_R.read(1) # consume byte

      case SIGNAL_QUEUE.shift
      when :INT, :QUIT, :TERM
        shutdown
      when :USR2
        reexec
      when :CHLD
        pid = Process.wait

        if CHILD_PIDS.delete(pid)
          spawn_worker
        end
      end
    end
  end
  
  def trap_signals
    [:INT, :QUIT, :TERM, :USR2, :CHLD].each do |sig|
      Signal.trap(sig) { 
        SIGNAL_QUEUE << sig
        SELF_PIPE_W.write_nonblock('.')
      }
    end
  end

  # shell
  #   $ ruby foo.rb
  #
  #   # how the shell spawns commands
  #   pid = fork {
  #     exec 'ruby mini-unicorn.rb'
  #       => fork { exec }
  #   }
  #
  #   wait(pid)
  #

  def reexec
    fork {
      $PROGRAM_NAME = "MiniUnicorn (New master)"

      ENV['LISTENER_FD'] = @listener.fileno.to_s
      exec "ruby mini-unicorn.rb", {@listener.fileno => @listener}
    }
  end

  def shutdown
    CHILD_PIDS.each do |cpid|
      Process.kill(:INT, cpid)
    end
    
    sleep 5
    CHILD_PIDS.each do |cpid|
      begin
        Process.waitpid(cpid, Process::WNOHANG)
        Process.kill(:KILL, cpid)
      rescue Errno::ECHILD
      end
    end

    exit
  end

  def set_title
    $PROGRAM_NAME = "MiniUnicorn master"
  end

  # config
  #
  # after_fork do
  #   ActiveRecord::Base.establish_connection
  #   Redis::Client.reconnect
  # end
  # 

  def spawn_workers
    NUM_WORKERS.times do |num|
      spawn_worker(num)
    end
  end

  def spawn_worker(num)
    CHILD_PIDS << fork {
      $PROGRAM_NAME = "MiniUnicorn worker ##{num}"
      trap_child_signals
      worker_loop
    }
  end

  def load_app
    rackup_file = ENV.fetch('RU') { 'config.ru' }
    @app, options = Rack::Builder.parse_file(rackup_file)
  end

  def trap_child_signals
    Signal.trap(:INT) {
      @should_exit = true
    }
  end

  def worker_loop
    loop do
      connection, _ = @listener.accept
      
      # read = lazy read
      # block until it gets EOF
      #
      # readpartial = greedy read
      
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

