require 'socket'
require 'rack'
require 'rack/builder'
require 'http_tools'

class MiniUnicorn
  NUM_WORKERS = 12
  WORKER_PIDS = []
  SIGNAL_QUEUE = []
  
  def initialize(port = 8080)
    if lfd = ENV['LISTENER_FD']
      @listener = TCPServer.for_fd(lfd.to_i)
    else
      @listener = TCPServer.new(port)
    end
  end

  def load_app
    rackup_file = ENV.fetch('RU') { './config.ru' }
    @app, options = Rack::Builder.parse_file(rackup_file)
  end

  def spawn_workers
    NUM_WORKERS.times do
      spawn_worker
    end
  end

  def spawn_worker
    WORKER_PIDS << Process.fork {
      $PROGRAM_NAME = "MiniUnicorn (worker)"
      worker_loop
    }
  end

  def trap_signals
    [:INT, :QUIT, :USR2, :CHLD].each do |sig|
      Signal.trap(sig) {
        SIGNAL_QUEUE << sig
      }
    end
  end

  def start
    load_app
    spawn_workers
    trap_signals
    $PROGRAM_NAME = "MiniUnicorn (master)"

    loop do
      case SIGNAL_QUEUE.shift
      when nil
        sleep 1

      when :INT, :QUIT
        WORKER_PIDS.each do |wpid|
          Process.kill(:QUIT, wpid)
        end

        # we can no longer do waitall here
        # because that will also attempt to 
        # wait for the new master!
        WORKER_PIDS.each do |wpid|
          Process.waitpid(wpid)
        end
        exit

      when :USR2
        reexec

      when :CHLD
        pid, status = Process.wait2

        if WORKER_PIDS.include?(pid)
          WORKER_PIDS.delete(pid)
          spawn_worker
        end
      end
    end
  end

  def reexec
    puts "starting reexec..."

    fork {
      @listener.close_on_exec = false
      ENV['LISTENER_FD'] = @listener.fileno.to_s

      exec('ruby', 'mini_unicorn.rb', {@listener.fileno => @listener})
    }

    $PROGRAM_NAME = "MiniUnicorn (old master)"
  end

#  = old_master
#    \= worker #1
#    \= worker #2
#    \= new_master
#      \= worker #1
#      \= worker #2
#

  def worker_loop
    # TODO: before fork

    loop do
      # accept(2)
      client = @listener.accept

      parser = HTTPTools::Parser.new
      
      parser.on(:finish) do
        env = parser.env.merge!("rack.multiprocess" => true)
        status, header, body = @app.call(env)
        
        header["Connection"] = "close"
        client.write HTTPTools::Builder.response(status, header)

        body.each {|chunk| client.write chunk}
        body.close if body.respond_to?(:close)
      end
      
      # IO.read() reads until EOF
      # readpartial() greedy
      # read() is lazy
      request = client.readpartial(4096)
      parser << request
     
      client.close
    end
  end
end

uni = MiniUnicorn.new
uni.start

