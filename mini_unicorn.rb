require 'socket'
require 'rack'
require 'rack/builder'
require 'http_tools'

class MiniUnicorn
  NUM_WORKERS = 12
  WORKER_PIDS = []
  
  def initialize(port = 8080)
    @listener = TCPServer.new(port)
  end

  def load_app
    rackup_file = ENV.fetch('RU') { './config.ru' }
    @app, options = Rack::Builder.parse_file(rackup_file)
  end

  def start
    load_app

    NUM_WORKERS.times do
      WORKER_PIDS << Process.fork {
        worker_loop
      }
    end

    Signal.trap(:USR2) do
      reexec
    end
    
    Process.waitall
  end

  def reexec
    puts "starting reexec..."

    fork {
    }

  end

  def worker_loop
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

